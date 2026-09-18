package com.shadow.backend.chat.service.impl;

import com.shadow.backend.chat.entity.ChatOutbox;
import com.shadow.backend.chat.mapper.ChatOutboxMapper;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ChatOutboxStoreImplTest {
    @Mock private ChatOutboxMapper mapper;
    @InjectMocks private ChatOutboxStoreImpl store;

    @Test
    void eachClaimHasNewUuidAndReadsOnlyItsOwnToken() {
        when(mapper.claim(eq(1L), anyString(), eq(60))).thenReturn(1);
        when(mapper.findClaim(eq(1L), anyString())).thenAnswer(call -> claim(call.getArgument(1)));
        ChatOutbox first = store.claim(1L, 60).orElseThrow();
        ChatOutbox recovered = store.claim(1L, 60).orElseThrow();
        assertThat(first.getClaimToken()).isNotEqualTo(recovered.getClaimToken());
        UUID.fromString(first.getClaimToken());
        UUID.fromString(recovered.getClaimToken());
        var tokens = ArgumentCaptor.forClass(String.class);
        verify(mapper, times(2)).claim(eq(1L), tokens.capture(), eq(60));
        assertThat(tokens.getAllValues()).containsExactly(first.getClaimToken(), recovered.getClaimToken());
        verify(mapper).findClaim(1L, first.getClaimToken());
        verify(mapper).findClaim(1L, recovered.getClaimToken());
    }

    @Test
    void losingClaimDoesNotReadOrPublishAnotherWorkersRow() {
        when(mapper.claim(eq(1L), anyString(), eq(60))).thenReturn(0);
        assertThat(store.claim(1L, 60)).isEmpty();
        verify(mapper, never()).findClaim(any(), any());
    }

    @Test
    void leaseExpiredBeforeReadReturnsNoClaim() {
        when(mapper.claim(eq(1L), anyString(), eq(1))).thenReturn(1);
        when(mapper.findClaim(eq(1L), anyString())).thenReturn(null);
        assertThat(store.claim(1L, 1)).isEmpty();
    }

    @Test
    void staleTokenCannotAcknowledgeOrRescheduleNewOwner() {
        ChatOutbox old = claim(UUID.randomUUID().toString());
        ChatOutbox current = claim(UUID.randomUUID().toString());
        when(mapper.acknowledge(1L, old.getClaimToken())).thenReturn(0);
        when(mapper.acknowledge(1L, current.getClaimToken())).thenReturn(1);
        when(mapper.retry(1L, old.getClaimToken(), 2L, "IOException")).thenReturn(0);
        assertThat(store.acknowledge(old)).isFalse();
        assertThat(store.retry(old, new IOException("敏感正文和凭证"))).isFalse();
        assertThat(store.acknowledge(current)).isTrue();
    }

    @Test
    void failureStoresOnlyExceptionTypeAndExponentialDelay() {
        ChatOutbox row = claim("token");
        row.setAttempts(5);
        when(mapper.retry(1L, "token", 32L, "IOException")).thenReturn(1);
        assertThat(store.retry(row, new IOException("正文=敏感;密码=秘密"))).isTrue();
        verify(mapper).retry(1L, "token", 32L, "IOException");
        verify(mapper, never()).acknowledge(any(), any());
    }

    @ParameterizedTest
    @CsvSource({"0,2", "1,2", "2,4", "5,32", "11,2048", "12,3600", "2147483647,3600"})
    void retryBackoffIsBoundedWithoutDroppingEvent(int attempts, long delay) {
        assertThat(ChatOutboxStoreImpl.retryDelay(attempts)).isEqualTo(delay);
    }

    @Test
    void migrationProbeRequiresAllThreeInnoDbTables() {
        when(mapper.countReadyTables()).thenReturn(0, 1, 2, 3);
        assertThat(store.isReady()).isFalse();
        assertThat(store.isReady()).isFalse();
        assertThat(store.isReady()).isFalse();
        assertThat(store.isReady()).isTrue();
    }

    @Test
    void storeUsesSeparateShortTransactions() {
        Transactional annotation = ChatOutboxStoreImpl.class.getAnnotation(Transactional.class);
        assertThat(annotation.propagation()).isEqualTo(Propagation.REQUIRES_NEW);
    }

    private ChatOutbox claim(String token) {
        ChatOutbox row = new ChatOutbox();
        row.setId(1L);
        row.setClaimToken(token);
        row.setAttempts(1);
        return row;
    }
}
