package com.shadow.backend.chat.service.impl;

import com.shadow.backend.chat.entity.ChatOutbox;
import com.shadow.backend.chat.mapper.ChatOutboxMapper;
import com.shadow.backend.chat.service.ChatOutboxStore;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional(propagation = Propagation.REQUIRES_NEW)
public class ChatOutboxStoreImpl implements ChatOutboxStore {
    private final ChatOutboxMapper outboxMapper;

    @Override
    public boolean isReady() {
        return outboxMapper.countReadyTables() == 3;
    }

    @Override
    public List<Long> candidates(int limit) {
        return outboxMapper.findCandidates(limit);
    }

    @Override
    public Optional<ChatOutbox> claim(Long id, int leaseSeconds) {
        String token = UUID.randomUUID().toString();
        if (outboxMapper.claim(id, token, leaseSeconds) != 1) {
            return Optional.empty();
        }
        return Optional.ofNullable(outboxMapper.findClaim(id, token));
    }

    @Override
    public boolean acknowledge(ChatOutbox claim) {
        return outboxMapper.acknowledge(claim.getId(), claim.getClaimToken()) == 1;
    }

    @Override
    public boolean retry(ChatOutbox claim, Exception failure) {
        // 仅保留异常类型，不信任外部发布器异常的 message、cause 或堆栈。
        String error = failure.getClass().getSimpleName().replaceAll("[^a-zA-Z0-9_$]", "_");
        if (error.isEmpty()) {
            error = "Exception";
        }
        error = error.substring(0, Math.min(128, error.length()));
        return outboxMapper.retry(claim.getId(), claim.getClaimToken(), retryDelay(claim.getAttempts()), error) == 1;
    }

    static long retryDelay(int attempts) {
        // 首次失败 2 秒，指数增长至 1 小时；不丢弃事件，不设置最大重试次数。
        return Math.min(3600L, 1L << Math.min(12, Math.max(1, attempts)));
    }
}
