package com.shadow.backend.chat.service;

/**
 * 实时模块实现此接口，以 QoS 1、非 retained 方式发布，并在有界超时内确认 Broker 接收。
 * 正常返回只表示 Broker 接收，不表示设备送达或用户已读；重复投递由 eventId 去重。
 * 抛出异常时 Outbox 保留事件并重试，异常消息不得被当作安全日志直接记录。
 */
public interface ChatEventPublisher {

    void publish(String topic, String payload) throws Exception;
}
