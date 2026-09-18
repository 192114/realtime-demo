package com.shadow.backend.chat.service.impl;

import com.shadow.backend.chat.config.ChatOutboxProperties;
import com.shadow.backend.chat.entity.ChatOutbox;
import com.shadow.backend.chat.service.ChatEventPublisher;
import com.shadow.backend.chat.service.ChatOutboxStore;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ChatOutboxDispatcherImplTest {
    @Mock private ChatOutboxStore store;
    @Mock private ObjectProvider<ChatEventPublisher> publishers;
    @Mock private ChatEventPublisher publisher;

    @Test
    void absentPublisherDoesNotTouchDatabase() {
        dispatcher().dispatch();
        verifyNoInteractions(store);
    }

    @Test
    void absentMigrationDoesNotClaimOrPublish() {
        when(publishers.getIfAvailable()).thenReturn(publisher);
        when(store.isReady()).thenReturn(false);
        dispatcher().dispatch();
        verify(store, never()).candidates(anyInt());
        verifyNoInteractions(publisher);
    }

    @Test
    void publishesOnlyClaimedRowsAndAcknowledgesAfterPublish() throws Exception {
        ready();
        ChatOutbox row = row(2L, "new-token");
        when(store.candidates(50)).thenReturn(List.of(1L, 2L));
        when(store.claim(1L, 60)).thenReturn(Optional.empty());
        when(store.claim(2L, 60)).thenReturn(Optional.of(row));
        when(store.acknowledge(row)).thenReturn(true);
        dispatcher().dispatch();
        var order = inOrder(store, publisher);
        order.verify(store).isReady();
        order.verify(store).candidates(50);
        order.verify(store).claim(1L, 60);
        order.verify(store).claim(2L, 60);
        order.verify(publisher).publish(row.getTopic(), row.getPayload());
        order.verify(store).acknowledge(row);
        verify(store, never()).retry(any(), any());
    }

    @Test
    void publishFailureRetriedAndLaterClaimCanSucceed() throws Exception {
        ready();
        ChatOutbox first = row(1L, "first-token");
        ChatOutbox retry = row(1L, "retry-token");
        IOException failure = new IOException("不能记录的正文和凭证");
        when(store.candidates(50)).thenReturn(List.of(1L));
        when(store.claim(1L, 60)).thenReturn(Optional.of(first), Optional.of(retry));
        doThrow(failure).doNothing().when(publisher).publish(first.getTopic(), first.getPayload());
        when(store.retry(first, failure)).thenReturn(true);
        when(store.acknowledge(retry)).thenReturn(true);
        var dispatcher = dispatcher();
        dispatcher.dispatch();
        verify(store).retry(first, failure);
        verify(store, never()).acknowledge(first);
        dispatcher.dispatch();
        verify(store).acknowledge(retry);
        verify(publisher, times(2)).publish(first.getTopic(), first.getPayload());
    }

    @Test
    void expiredPublishConfirmationDoesNotOverwriteNewLease() throws Exception {
        ready();
        ChatOutbox old = row(1L, "expired-token");
        when(store.candidates(50)).thenReturn(List.of(1L));
        when(store.claim(1L, 60)).thenReturn(Optional.of(old));
        when(store.acknowledge(old)).thenReturn(false);
        dispatcher().dispatch();
        verify(publisher).publish(old.getTopic(), old.getPayload());
        verify(store, never()).retry(any(), any());
    }

    @Test
    void databaseFailureAfterBrokerSuccessLeavesRecoveryToLease() throws Exception {
        ready();
        ChatOutbox row = row(1L, "token");
        when(store.candidates(50)).thenReturn(List.of(1L));
        when(store.claim(1L, 60)).thenReturn(Optional.of(row));
        when(store.acknowledge(row)).thenThrow(new IllegalStateException("数据库故障"));
        assertThatThrownBy(() -> dispatcher().dispatch()).isInstanceOf(IllegalStateException.class);
        verify(publisher).publish(row.getTopic(), row.getPayload());
        verify(store, never()).retry(any(), any());
    }

    @Test
    void onePublishFailureDoesNotBlockOtherRecipients() throws Exception {
        ready();
        ChatOutbox first = row(1L, "one");
        ChatOutbox second = row(2L, "two");
        when(store.candidates(50)).thenReturn(List.of(1L, 2L));
        when(store.claim(1L, 60)).thenReturn(Optional.of(first));
        when(store.claim(2L, 60)).thenReturn(Optional.of(second));
        doThrow(new IOException()).when(publisher).publish(first.getTopic(), first.getPayload());
        dispatcher().dispatch();
        verify(store).retry(eq(first), any(IOException.class));
        verify(publisher).publish(second.getTopic(), second.getPayload());
        verify(store).acknowledge(second);
    }

    @Test
    void interruptedPublishRestoresInterruptAndStopsBatch() throws Exception {
        ready();
        ChatOutbox row = row(1L, "token");
        when(store.candidates(50)).thenReturn(List.of(1L, 2L));
        when(store.claim(1L, 60)).thenReturn(Optional.of(row));
        doThrow(new InterruptedException()).when(publisher).publish(row.getTopic(), row.getPayload());
        try {
            dispatcher().dispatch();
            assertThat(Thread.currentThread().isInterrupted()).isTrue();
            verify(store, never()).claim(2L, 60);
        } finally {
            Thread.interrupted();
        }
    }

    @Test
    void publisherInvocationSuspendsAnyAmbientTransaction() throws Exception {
        Transactional annotation = ChatOutboxDispatcherImpl.class.getMethod("dispatch").getAnnotation(Transactional.class);
        assertThat(annotation.propagation()).isEqualTo(Propagation.NOT_SUPPORTED);
    }

    private ChatOutboxDispatcherImpl dispatcher() {
        return new ChatOutboxDispatcherImpl(store, publishers, new ChatOutboxProperties());
    }

    private void ready() {
        when(publishers.getIfAvailable()).thenReturn(publisher);
        when(store.isReady()).thenReturn(true);
    }

    private ChatOutbox row(Long id, String token) {
        ChatOutbox row = new ChatOutbox();
        row.setId(id);
        row.setClaimToken(token);
        row.setAttempts(1);
        row.setTopic("chat/user/" + id + "/events");
        row.setPayload("事件正文");
        return row;
    }
}
