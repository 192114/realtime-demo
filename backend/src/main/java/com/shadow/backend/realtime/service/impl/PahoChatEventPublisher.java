package com.shadow.backend.realtime.service.impl;

import com.shadow.backend.chat.service.ChatEventPublisher;
import com.shadow.backend.realtime.config.PahoMqttClientFactory;
import com.shadow.backend.realtime.config.RealtimeMqttProperties;
import com.shadow.backend.realtime.security.RealtimeTopics;
import jakarta.annotation.PreDestroy;
import lombok.RequiredArgsConstructor;
import org.eclipse.paho.client.mqttv3.MqttAsyncClient;
import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.eclipse.paho.client.mqttv3.MqttMessage;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import java.util.concurrent.locks.ReentrantLock;

@Service
@ConditionalOnProperty(prefix = "realtime.mqtt", name = "enabled", havingValue = "true")
@RequiredArgsConstructor
public class PahoChatEventPublisher implements ChatEventPublisher {
    private final RealtimeMqttProperties properties;
    private final PahoMqttClientFactory clientFactory;
    private final ReentrantLock publishLock = new ReentrantLock();
    private MqttAsyncClient client;
    private volatile boolean closed;

    @Override
    public void publish(String topic, String payload) throws Exception {
        if (!properties.isEnabled() || closed) {
            throw new IllegalStateException("实时消息发布器未启用或已关闭");
        }
        if (!RealtimeTopics.isPersonalTopic(topic) || payload == null) {
            throw new IllegalArgumentException("实时消息发布参数无效");
        }
        boolean locked = false;
        try {
            long lockTimeout = properties.getConnectTimeoutSeconds() + properties.getPublishTimeoutSeconds();
            locked = publishLock.tryLock(lockTimeout, TimeUnit.SECONDS);
            if (!locked || closed) {
                throw new TimeoutException();
            }
            ensureConnected();
            MqttMessage message = new MqttMessage(payload.getBytes(StandardCharsets.UTF_8));
            message.setQos(1);
            message.setRetained(false);
            // 等待 PUBACK；超时结果不确定，不在此处重复发送，交由 Outbox 按 eventId 重试。
            client.publish(topic, message).waitForCompletion(properties.getPublishTimeoutSeconds() * 1000L);
        } catch (InterruptedException ex) {
            Thread.currentThread().interrupt();
            throw new InterruptedException("实时消息发布被中断");
        } catch (Exception ex) {
            // Paho 异常可能包含网络地址或消息信息，向调用方仅暴露固定消息且不保留 cause。
            throw new IllegalStateException("实时消息发布失败或超时");
        } finally {
            if (locked) {
                publishLock.unlock();
            }
        }
    }

    private void ensureConnected() throws Exception {
        if (client == null) {
            client = clientFactory.create(properties);
            try {
                client.connect(connectOptions()).waitForCompletion(properties.getConnectTimeoutSeconds() * 1000L);
            } catch (Exception ex) {
                closeClient();
                throw ex;
            }
        }
        // 既有连接由 Paho 自动指数退避重连；避免并发 connect 与自动重连互相干扰。
        long deadline = System.nanoTime() + TimeUnit.SECONDS.toNanos(properties.getConnectTimeoutSeconds());
        while (!client.isConnected()) {
            long remaining = deadline - System.nanoTime();
            if (remaining <= 0 || closed) {
                throw new TimeoutException();
            }
            TimeUnit.NANOSECONDS.sleep(Math.min(remaining, TimeUnit.MILLISECONDS.toNanos(25)));
        }
    }

    private MqttConnectOptions connectOptions() {
        MqttConnectOptions options = new MqttConnectOptions();
        options.setMqttVersion(MqttConnectOptions.MQTT_VERSION_3_1_1);
        options.setCleanSession(true);
        options.setAutomaticReconnect(true);
        options.setMaxReconnectDelay(properties.getMaxReconnectDelayMillis());
        options.setConnectionTimeout(properties.getConnectTimeoutSeconds());
        options.setKeepAliveInterval(properties.getKeepAliveSeconds());
        options.setHttpsHostnameVerificationEnabled(true);
        options.setUserName(properties.getServiceUsername());
        options.setPassword(properties.getServicePassword().toCharArray());
        return options;
    }

    @PreDestroy
    public void close() {
        closed = true;
        publishLock.lock();
        try {
            closeClient();
        } finally {
            publishLock.unlock();
        }
    }

    private void closeClient() {
        if (client == null) {
            return;
        }
        try {
            client.disconnectForcibly(0, 1000, false);
        } catch (Exception ignored) {
            // 即使连接已损坏也必须尝试关闭重连线程，不记录下游异常。
        }
        try {
            client.close(true);
        } catch (Exception ignored) {
            // 关闭阶段不传播敏感网络信息。
        } finally {
            client = null;
        }
    }
}
