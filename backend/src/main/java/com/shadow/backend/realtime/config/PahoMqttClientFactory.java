package com.shadow.backend.realtime.config;

import org.eclipse.paho.client.mqttv3.MqttAsyncClient;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;
import org.springframework.stereotype.Component;

@Component
public class PahoMqttClientFactory {
    public MqttAsyncClient create(RealtimeMqttProperties properties) throws MqttException {
        // 不落地消息正文；失败重试由 chat Outbox 持久化层负责。
        return new MqttAsyncClient(properties.getServerUri(), properties.getServiceClientId(), new MemoryPersistence());
    }
}
