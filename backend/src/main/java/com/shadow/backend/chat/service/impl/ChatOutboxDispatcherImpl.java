package com.shadow.backend.chat.service.impl;

import com.shadow.backend.chat.config.ChatOutboxProperties;
import com.shadow.backend.chat.entity.ChatOutbox;
import com.shadow.backend.chat.service.ChatEventPublisher;
import com.shadow.backend.chat.service.ChatOutboxDispatcher;
import com.shadow.backend.chat.service.ChatOutboxStore;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class ChatOutboxDispatcherImpl implements ChatOutboxDispatcher {
    private final ChatOutboxStore store;
    private final ObjectProvider<ChatEventPublisher> publishers;
    private final ChatOutboxProperties properties;

    @Override
    @Transactional(propagation = Propagation.NOT_SUPPORTED)
    public void dispatch() {
        ChatEventPublisher publisher = publishers.getIfAvailable();
        // 未迁移或未安装实时发布器时不访问 Outbox 业务表，不影响核心聊天 API。
        if (publisher == null || !store.isReady()) {
            return;
        }
        for (Long id : store.candidates(properties.getBatchSize())) {
            if (Thread.currentThread().isInterrupted()) {
                return;
            }
            // 逐条临近发布时抢占，避免整个批次在前面任务发布时耗尽租约。
            ChatOutbox claim = store.claim(id, properties.getLeaseSeconds()).orElse(null);
            if (claim == null) {
                continue;
            }
            try {
                // claim 事务已经提交；网络调用绝不持有会话锁或 Outbox 行锁。
                publisher.publish(claim.getTopic(), claim.getPayload());
            } catch (Exception failure) {
                boolean updated = store.retry(claim, failure);
                log.warn("聊天事件发布失败，已安排重试: outboxId={}, attempts={}, leaseOwned={}",
                        claim.getId(), claim.getAttempts(), updated);
                if (failure instanceof InterruptedException) {
                    Thread.currentThread().interrupt();
                    return;
                }
                continue;
            }
            // Broker 成功而确认写库失败时由租约恢复重发，允许重复，不允许丢失。
            if (!store.acknowledge(claim)) {
                log.info("聊天事件租约已失效，忽略旧发布者确认: outboxId={}", claim.getId());
            }
        }
    }
}
