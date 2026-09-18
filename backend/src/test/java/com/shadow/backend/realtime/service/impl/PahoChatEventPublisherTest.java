package com.shadow.backend.realtime.service.impl;

import com.shadow.backend.realtime.config.PahoMqttClientFactory;
import com.shadow.backend.realtime.config.RealtimeMqttProperties;
import org.eclipse.paho.client.mqttv3.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.nio.charset.StandardCharsets;
import java.time.Duration;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.junit.jupiter.api.Assertions.assertTimeoutPreemptively;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class PahoChatEventPublisherTest {
    private final RealtimeMqttProperties properties = new RealtimeMqttProperties();
    private final PahoMqttClientFactory factory = mock(PahoMqttClientFactory.class);
    private final MqttAsyncClient client = mock(MqttAsyncClient.class);
    private final IMqttToken connection = mock(IMqttToken.class);
    private final IMqttDeliveryToken delivery = mock(IMqttDeliveryToken.class);
    private PahoChatEventPublisher publisher;

    @BeforeEach
    void setup() throws Exception {
        properties.setEnabled(true);
        properties.setServiceUsername("test-service");
        properties.setServicePassword("unit-test-service-password-not-deployed");
        properties.setConnectTimeoutSeconds(1);
        properties.setPublishTimeoutSeconds(1);
        when(factory.create(properties)).thenReturn(client);
        when(client.connect(any(MqttConnectOptions.class))).thenReturn(connection);
        when(client.isConnected()).thenReturn(true);
        when(client.publish(anyString(), any(MqttMessage.class))).thenReturn(delivery);
        publisher = new PahoChatEventPublisher(properties, factory);
    }

    @Test
    void publishReusesConnectionAndWaitsForQosOneNonRetainedAckWithServiceIdentity() throws Exception {
        publisher.publish("chat/user/42/events", "测试消息");
        publisher.publish("chat/user/42/calls", "second");
        var options = ArgumentCaptor.forClass(MqttConnectOptions.class);
        verify(client).connect(options.capture());
        assertThat(options.getValue().getUserName()).isEqualTo(properties.getServiceUsername());
        assertThat(options.getValue().getPassword()).isEqualTo(properties.getServicePassword().toCharArray());
        assertThat(options.getValue().getMqttVersion()).isEqualTo(MqttConnectOptions.MQTT_VERSION_3_1_1);
        assertThat(options.getValue().isCleanSession()).isTrue();
        assertThat(options.getValue().isAutomaticReconnect()).isTrue();
        assertThat(options.getValue().isHttpsHostnameVerificationEnabled()).isTrue();
        assertThat(options.getValue().getConnectionTimeout()).isEqualTo(1);
        assertThat(options.getValue().getMaxReconnectDelay()).isEqualTo(30000);
        var message = ArgumentCaptor.forClass(MqttMessage.class);
        verify(client).publish(eq("chat/user/42/events"), message.capture());
        assertThat(message.getValue().getQos()).isEqualTo(1);
        assertThat(message.getValue().isRetained()).isFalse();
        assertThat(new String(message.getValue().getPayload(), StandardCharsets.UTF_8)).isEqualTo("测试消息");
        verify(connection).waitForCompletion(1000);
        verify(delivery, times(2)).waitForCompletion(1000);
        verify(factory).create(properties);
    }

    @Test
    void disconnectedClientWaitsForAutomaticReconnectWithoutCreatingNewConnection() throws Exception {
        publisher.publish("chat/user/42/events", "first");
        when(client.isConnected()).thenReturn(false, false, true);
        publisher.publish("chat/user/42/events", "second");
        verify(factory).create(properties);
        verify(client).connect(any(MqttConnectOptions.class));
        verify(client, times(2)).publish(anyString(), any(MqttMessage.class));
    }

    @Test
    void reconnectWaitIsFiniteAndDoesNotPretendPublishSucceeded() throws Exception {
        publisher.publish("chat/user/42/events", "first");
        when(client.isConnected()).thenReturn(false);
        assertTimeoutPreemptively(Duration.ofSeconds(3), () ->
                assertThatThrownBy(() -> publisher.publish("chat/user/42/events", "second"))
                        .isInstanceOf(IllegalStateException.class).hasNoCause());
        verify(client).publish(anyString(), any(MqttMessage.class));
    }

    @Test
    void initialConnectionFailureClosesClientAndNextCallCanRetry() throws Exception {
        doThrow(new MqttException(new IllegalStateException("sensitive-password")))
                .doNothing().when(connection).waitForCompletion(1000);
        assertThatThrownBy(() -> publisher.publish("chat/user/42/events", "sensitive-body"))
                .isInstanceOf(IllegalStateException.class).hasMessageNotContaining("sensitive").hasNoCause();
        verify(client).disconnectForcibly(0, 1000, false);
        verify(client).close(true);
        publisher.publish("chat/user/42/events", "retry");
        verify(factory, times(2)).create(properties);
    }

    @Test
    void publishTimeoutPropagatesSanitizedFailureWithoutInlineRepublish() throws Exception {
        doThrow(new MqttException(new IllegalStateException("sensitive-body"))).when(delivery).waitForCompletion(1000);
        assertThatThrownBy(() -> publisher.publish("chat/user/42/events", "sensitive-body"))
                .isInstanceOf(IllegalStateException.class).hasMessageNotContaining("sensitive-body").hasNoCause();
        verify(client).publish(anyString(), any(MqttMessage.class));
        verify(client, never()).close(true);
    }

    @Test
    void disabledInvalidTopicAndClosedPublisherNeverAccessBroker() {
        properties.setEnabled(false);
        assertThatThrownBy(() -> publisher.publish("chat/user/42/events", "body")).isInstanceOf(IllegalStateException.class);
        properties.setEnabled(true);
        for (String topic : new String[]{"chat/user/+/events", "$share/g/chat/user/42/events", "chat/user/0/events", "other"}) {
            assertThatThrownBy(() -> publisher.publish(topic, "body")).isInstanceOf(IllegalArgumentException.class);
        }
        publisher.close();
        assertThatThrownBy(() -> publisher.publish("chat/user/42/events", "body")).isInstanceOf(IllegalStateException.class);
        verifyNoInteractions(factory);
    }

    @Test
    void shutdownReleasesConnectionAndInterruptedThreadIsPreserved() throws Exception {
        publisher.publish("chat/user/42/events", "body");
        Thread.currentThread().interrupt();
        try {
            assertThatThrownBy(() -> publisher.publish("chat/user/42/events", "body")).isInstanceOf(InterruptedException.class);
            assertThat(Thread.currentThread().isInterrupted()).isTrue();
        } finally {
            Thread.interrupted();
        }
        publisher.close();
        verify(client).disconnectForcibly(0, 1000, false);
        verify(client).close(true);
    }
}
