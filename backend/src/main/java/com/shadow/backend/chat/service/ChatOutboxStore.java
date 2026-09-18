package com.shadow.backend.chat.service;

import com.shadow.backend.chat.entity.ChatOutbox;

import java.util.List;
import java.util.Optional;

public interface ChatOutboxStore {
    boolean isReady();

    List<Long> candidates(int limit);

    Optional<ChatOutbox> claim(Long id, int leaseSeconds);

    boolean acknowledge(ChatOutbox claim);

    boolean retry(ChatOutbox claim, Exception failure);
}
