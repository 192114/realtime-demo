package com.shadow.backend.chat.service.impl;

import com.shadow.backend.chat.dto.SendMessageRequest;
import com.shadow.backend.chat.entity.ChatConversation;
import com.shadow.backend.chat.entity.ChatMessage;
import com.shadow.backend.chat.entity.ChatOutbox;
import com.shadow.backend.chat.mapper.ChatConversationMapper;
import com.shadow.backend.chat.mapper.ChatMessageMapper;
import com.shadow.backend.chat.mapper.ChatOutboxMapper;
import com.shadow.backend.chat.service.ChatService;
import com.shadow.backend.chat.vo.ChatMessageVO;
import com.shadow.backend.common.config.JacksonConfig;
import com.shadow.backend.common.exception.BusinessException;
import com.shadow.backend.user.constant.AuditStatus;
import com.shadow.backend.user.entity.User;
import com.shadow.backend.user.mapper.UserMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;
import org.junit.jupiter.params.provider.ValueSource;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.aop.framework.ProxyFactory;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.annotation.AnnotationTransactionAttributeSource;
import org.springframework.transaction.interceptor.TransactionInterceptor;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

import java.time.Instant;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ChatServiceImplTest {
    private static final String CLIENT_ID = "aabbccdd-1234-4321-aaaa-123456789abc";
    @Mock private ChatConversationMapper conversationMapper;
    @Mock private ChatMessageMapper messageMapper;
    @Mock private ChatOutboxMapper outboxMapper;
    @Mock private UserMapper userMapper;
    private ChatServiceImpl service;
    private JsonMapper jsonMapper;
    private ChatConversation conversation;

    @BeforeEach
    void setUp() {
        var builder = JsonMapper.builder();
        new JacksonConfig().jsonMapperBuilderCustomizer().customize(builder);
        jsonMapper = builder.build();
        service = new ChatServiceImpl(conversationMapper, messageMapper, outboxMapper, userMapper, jsonMapper);
        conversation = new ChatConversation();
        conversation.setId(10L);
        conversation.setUserLowId(1L);
        conversation.setUserHighId(2L);
        conversation.setLastSeq(5L);
        conversation.setLowReadSeq(2L);
        conversation.setHighReadSeq(1L);
        conversation.setUpdatedAt(LocalDateTime.parse("2026-09-17T10:00:00"));
    }

    @Test
    void nonMemberCannotReadHistoryOrSyncOrSendOrMarkRead() {
        when(conversationMapper.selectById(10L)).thenReturn(conversation);
        when(conversationMapper.lockById(10L)).thenReturn(conversation);
        assertForbidden(() -> service.history(3L, 10L, null, 50));
        assertForbidden(() -> service.sync(3L, 10L, 0L, 100));
        assertForbidden(() -> service.send(3L, 10L, request("正文")));
        assertForbidden(() -> service.read(3L, 10L, 5L));
        verifyNoInteractions(messageMapper, outboxMapper, userMapper);
    }

    @Test
    void missingConversationHasSameErrorAsNonMember() {
        assertForbidden(() -> service.history(1L, 99L, null, 50));
        verifyNoInteractions(userMapper, messageMapper);
    }

    @Test
    void selfConversationRejectedBeforeDatabaseAccess() {
        assertThatThrownBy(() -> service.createDirect(1L, 1L)).isInstanceOf(BusinessException.class);
        verifyNoInteractions(userMapper, conversationMapper);
    }

    @ParameterizedTest
    @CsvSource({"1,0,1,0", "1,1,0,0", "1,1,2,0", "1,1,1,1", "2,0,1,0", "2,1,0,0", "2,1,2,0", "2,1,1,1"})
    void currentAndPeerMustBeActiveAndApproved(long rejectedId, int status, int audit, int deleted) {
        User rejected = user(rejectedId);
        rejected.setStatus(status);
        rejected.setAuditStatus(audit);
        rejected.setDeleted(deleted);
        when(userMapper.selectById(1L)).thenReturn(rejectedId == 1 ? rejected : user(1L));
        if (rejectedId == 2) {
            when(userMapper.selectById(2L)).thenReturn(rejected);
        }
        assertForbidden(() -> service.createDirect(1L, 2L));
        verifyNoInteractions(conversationMapper);
    }

    @Test
    void unknownOrMissingStateIsRejected() {
        User user = user(1L);
        user.setAuditStatus(null);
        when(userMapper.selectById(1L)).thenReturn(user);
        assertForbidden(() -> service.conversations(1L, null, 50));
        user.setAuditStatus(99);
        assertForbidden(() -> service.conversations(1L, null, 50));
        user.setAuditStatus(1);
        user.setStatus(null);
        assertForbidden(() -> service.conversations(1L, null, 50));
        when(userMapper.selectById(1L)).thenReturn(null);
        assertForbidden(() -> service.conversations(1L, null, 50));
    }

    @Test
    void canonicalPairAndUnreadOnlyCountPeerMessages() {
        when(userMapper.selectById(1L)).thenReturn(user(1L));
        when(userMapper.selectById(2L)).thenReturn(user(2L));
        when(conversationMapper.lockPair(1L, 2L)).thenReturn(conversation);
        when(messageMapper.countUnread(10L, 1L, 1L)).thenReturn(2L);
        var vo = service.createDirect(2L, 1L);
        verify(conversationMapper).createDirect(eq(1L), eq(2L), any());
        assertThat(vo.getConversationId()).isEqualTo(10L);
        assertThat(vo.getPeerUserId()).isEqualTo(1L);
        assertThat(vo.getReadSeq()).isEqualTo(1L);
        assertThat(vo.getPeerReadSeq()).isEqualTo(2L);
        assertThat(vo.getUnreadCount()).isEqualTo(2L);
        JsonNode json = jsonMapper.valueToTree(vo);
        assertThat(json.has("phone")).isFalse();
        assertThat(json.get("lastMessage").isNull()).isTrue();
        assertThat(json.get("updatedAt").asString()).isEqualTo("2026-09-17T10:00:00Z");
    }

    @Test
    void sendLocksBeforeIdempotencyAndWritesSequenceMessageAndTwoOutboxes() {
        access(true);
        when(messageMapper.insert(any(ChatMessage.class))).thenAnswer(call -> {
            ChatMessage row = call.getArgument(0);
            row.setId(9007199254740993L);
            return 1;
        });
        var vo = service.send(1L, 10L, request(" 原样文本 "));
        var order = inOrder(conversationMapper, messageMapper, outboxMapper);
        order.verify(conversationMapper).lockById(10L);
        order.verify(messageMapper).findIdempotent(10L, 1L, CLIENT_ID);
        order.verify(messageMapper).insert(any(ChatMessage.class));
        order.verify(conversationMapper).updateById(conversation);
        order.verify(outboxMapper, times(2)).insert(any(ChatOutbox.class));
        assertThat(vo.getSeq()).isEqualTo(6L);
        assertThat(vo.getType()).isEqualTo(ChatMessage.TYPE_TEXT);
        assertThat(vo.getCallId()).isNull();
        assertThat(conversation.getLastSeq()).isEqualTo(6L);
        assertThat(conversation.getLowReadSeq()).isEqualTo(2L);
        assertThat(vo.getText()).isEqualTo(" 原样文本 ");
        assertThat(Instant.parse(vo.getCreatedAt())).isNotNull();
        var rows = ArgumentCaptor.forClass(ChatOutbox.class);
        verify(outboxMapper, times(2)).insert(rows.capture());
        assertThat(rows.getAllValues()).extracting(ChatOutbox::getTopic)
                .containsExactly("chat/user/1/events", "chat/user/2/events");
        JsonNode event = jsonMapper.readTree(rows.getAllValues().getFirst().getPayload());
        UUID.fromString(event.get("eventId").asString());
        assertThat(event.get("eventType").asString()).isEqualTo("message.created");
        assertThat(event.get("version").isIntegralNumber()).isTrue();
        assertThat(event.get("version").asInt()).isEqualTo(1);
        assertThat(event.get("messageId").asString()).isEqualTo("9007199254740993");
        assertThat(event.get("seq").isString()).isTrue();
        assertThat(event.get("payload").get("type").asString()).isEqualTo("TEXT");
        assertThat(event.get("payload")).isEqualTo(jsonMapper.valueToTree(vo));
        assertThat(rows.getAllValues().get(1).getPayload()).isEqualTo(rows.getAllValues().getFirst().getPayload());
    }

    @Test
    void idempotentRetryReturnsOriginalWithoutSequenceOrEventChanges() {
        access(true);
        ChatMessage existing = message(5L);
        when(messageMapper.findIdempotent(10L, 1L, CLIENT_ID)).thenReturn(existing);
        assertThat(service.send(1L, 10L, request("正文")).getMessageId()).isEqualTo(existing.getId());
        verify(messageMapper, never()).insert(any(ChatMessage.class));
        verify(conversationMapper, never()).updateById(any(ChatConversation.class));
        verifyNoInteractions(outboxMapper);
        assertThat(conversation.getLastSeq()).isEqualTo(5L);
    }

    @Test
    void reusingIdWithDifferentTextConflicts() {
        access(true);
        when(messageMapper.findIdempotent(10L, 1L, CLIENT_ID)).thenReturn(message(5L));
        assertThatThrownBy(() -> service.send(1L, 10L, request("不同正文")))
                .isInstanceOf(BusinessException.class).extracting("code").isEqualTo(409);
        verifyNoInteractions(outboxMapper);
    }

    @Test
    void clientIdCaseIsPreservedAndSequenceDoesNotOverflow() {
        access(true);
        conversation.setLastSeq(Long.MAX_VALUE);
        var request = request("正文");
        request.setClientMsgId(CLIENT_ID.toUpperCase());
        assertThatThrownBy(() -> service.send(1L, 10L, request)).isInstanceOf(BusinessException.class);
        verify(messageMapper).findIdempotent(10L, 1L, CLIENT_ID.toUpperCase());
        verifyNoInteractions(outboxMapper);
    }

    @ParameterizedTest
    @ValueSource(longs = {0, 1, 2})
    void readNeverRegressesAndNoOpDoesNotEmit(long seq) {
        access(true);
        assertThat(service.read(1L, 10L, seq).getReadSeq()).isEqualTo(2L);
        verify(conversationMapper, never()).updateById(any(ChatConversation.class));
        verifyNoInteractions(outboxMapper);
    }

    @ParameterizedTest
    @ValueSource(longs = {1, 2})
    void readClampsToLastSeqAndPublishesToBothMembers(long userId) {
        access(true);
        assertThat(service.read(userId, 10L, Long.MAX_VALUE).getReadSeq()).isEqualTo(5L);
        assertThat(userId == 1 ? conversation.getLowReadSeq() : conversation.getHighReadSeq()).isEqualTo(5L);
        var rows = ArgumentCaptor.forClass(ChatOutbox.class);
        verify(outboxMapper, times(2)).insert(rows.capture());
        JsonNode event = jsonMapper.readTree(rows.getValue().getPayload());
        assertThat(event.get("eventType").asString()).isEqualTo("conversation.read");
        assertThat(event.get("messageId").isNull()).isTrue();
        assertThat(event.get("payload").get("userId").asString()).isEqualTo(Long.toString(userId));
        assertThat(event.get("payload").get("readSeq").asString()).isEqualTo("5");
        assertThat(event.get("seq").asString()).isEqualTo("5");
    }

    @Test
    void historyAndSyncUseOppositeOrderAndLimitPlusOne() {
        access(false);
        when(messageMapper.history(10L, 8L, 3)).thenReturn(List.of(message(7L), message(6L), message(5L)));
        when(messageMapper.sync(10L, 4L, 3)).thenReturn(List.of(message(5L), message(6L), message(7L)));
        var history = service.history(1L, 10L, 8L, 2);
        assertThat(history.getItems()).extracting(ChatMessageVO::getSeq).containsExactly(7L, 6L);
        assertThat(history.isHasMore()).isTrue();
        assertThat(history.getNextCursor()).isEqualTo(6L);
        var sync = service.sync(1L, 10L, 4L, 2);
        assertThat(sync.getItems()).extracting(ChatMessageVO::getSeq).containsExactly(5L, 6L);
        assertThat(sync.isHasMore()).isTrue();
        assertThat(sync.getNextCursor()).isEqualTo(6L);
    }

    @Test
    void emptySyncAndConversationListUseExplicitNullCursor() {
        access(false);
        when(messageMapper.sync(10L, 5L, 101)).thenReturn(List.of());
        var page = service.sync(1L, 10L, 5L, 100);
        assertThat(page.isHasMore()).isFalse();
        assertThat(jsonMapper.valueToTree(page).get("nextCursor").isNull()).isTrue();
        when(conversationMapper.findPage(1L, 11L, 2, 1)).thenReturn(List.of(conversation, conversation));
        var conversations = service.conversations(1L, 11L, 1);
        assertThat(conversations.getItems()).hasSize(1);
        assertThat(conversations.isHasMore()).isTrue();
        assertThat(conversations.getNextCursor()).isEqualTo(10L);
    }

    @Test
    void validationRejectsInvalidCursorLimitAndMessageBeforeDatabase() {
        assertThatThrownBy(() -> service.history(1L, 10L, 0L, 50)).isInstanceOf(BusinessException.class);
        assertThatThrownBy(() -> service.sync(1L, 10L, -1L, 100)).isInstanceOf(BusinessException.class);
        assertThatThrownBy(() -> service.sync(1L, 10L, 0L, 501)).isInstanceOf(BusinessException.class);
        assertThatThrownBy(() -> service.conversations(1L, null, 0)).isInstanceOf(BusinessException.class);
        assertThatThrownBy(() -> service.read(1L, 10L, -1L)).isInstanceOf(BusinessException.class);
        assertThatThrownBy(() -> service.send(1L, 10L, request(" "))).isInstanceOf(BusinessException.class);
        assertThatThrownBy(() -> service.send(1L, 10L, request("文".repeat(4001)))).isInstanceOf(BusinessException.class);
        var request = request("正文");
        request.setClientMsgId("a".repeat(10000));
        assertThatThrownBy(() -> service.send(1L, 10L, request)).isInstanceOf(BusinessException.class);
        verifyNoInteractions(conversationMapper, messageMapper, outboxMapper, userMapper);
    }

    @Test
    void outboxFailureRollsBackTheBusinessTransaction() {
        access(true);
        doThrow(new IllegalStateException("数据库不可用")).when(outboxMapper).insert(any(ChatOutbox.class));
        PlatformTransactionManager manager = mock(PlatformTransactionManager.class);
        TransactionStatus status = mock(TransactionStatus.class);
        when(manager.getTransaction(any())).thenReturn(status);
        var interceptor = new TransactionInterceptor();
        interceptor.setTransactionManager(manager);
        interceptor.setTransactionAttributeSource(new AnnotationTransactionAttributeSource());
        ProxyFactory factory = new ProxyFactory(service);
        factory.addAdvice(interceptor);
        ChatService proxy = (ChatService) factory.getProxy();
        assertThatThrownBy(() -> proxy.send(1L, 10L, request("正文"))).isInstanceOf(IllegalStateException.class);
        verify(manager).rollback(status);
        verify(manager, never()).commit(any());
    }

    @Test
    void repeatedSendDoesNotConsumeSequenceAndBothSendersShareOneSequence() {
        access(true);
        var persisted = new java.util.HashMap<String, ChatMessage>();
        when(messageMapper.findIdempotent(eq(10L), anyLong(), anyString())).thenAnswer(call ->
                persisted.get(call.getArgument(1) + ":" + call.getArgument(2)));
        when(messageMapper.insert(any(ChatMessage.class))).thenAnswer(call -> {
            ChatMessage row = call.getArgument(0);
            row.setId(100L + row.getSeq());
            persisted.put(row.getSenderId() + ":" + row.getClientMsgId(), row);
            return 1;
        });
        assertThat(service.send(1L, 10L, request("正文")).getSeq()).isEqualTo(6L);
        assertThat(service.send(1L, 10L, request("正文")).getSeq()).isEqualTo(6L);
        var next = request("第二条");
        next.setClientMsgId(UUID.randomUUID().toString());
        assertThat(service.send(1L, 10L, next).getSeq()).isEqualTo(7L);
        assertThat(service.send(2L, 10L, request("对端复用同一客户端ID")).getSeq()).isEqualTo(8L);
        assertThat(conversation.getLastSeq()).isEqualTo(8L);
        verify(messageMapper, times(3)).insert(any(ChatMessage.class));
        verify(outboxMapper, times(6)).insert(any(ChatOutbox.class));
    }

    @Test
    void stringIdsDeserializeWithoutPrecisionLossAndCursorHasExpectedName() {
        var direct = jsonMapper.readValue("{\"peerUserId\":\"9007199254740993\"}",
                com.shadow.backend.chat.dto.CreateDirectConversationRequest.class);
        var read = jsonMapper.readValue("{\"seq\":\"9007199254740993\"}",
                com.shadow.backend.chat.dto.ReadConversationRequest.class);
        assertThat(direct.getPeerUserId()).isEqualTo(9007199254740993L);
        assertThat(read.getSeq()).isEqualTo(9007199254740993L);
        var page = new com.shadow.backend.chat.vo.ChatCursorPageVO<>(List.of(), false, null);
        JsonNode json = jsonMapper.valueToTree(page);
        assertThat(json.get("hasMore").asBoolean()).isFalse();
        assertThat(json.get("nextCursor").isNull()).isTrue();
        assertThat(json.get("items").isArray()).isTrue();
    }

    private void access(boolean lock) {
        if (lock) {
            when(conversationMapper.lockById(10L)).thenReturn(conversation);
        } else {
            when(conversationMapper.selectById(10L)).thenReturn(conversation);
        }
        when(userMapper.selectById(1L)).thenReturn(user(1L));
        when(userMapper.selectById(2L)).thenReturn(user(2L));
    }

    private User user(Long id) {
        User user = new User();
        user.setId(id);
        user.setStatus(1);
        user.setAuditStatus(AuditStatus.APPROVED.getValue());
        user.setDeleted(0);
        user.setNickname("昵称" + id);
        user.setPhone("13800000000");
        return user;
    }

    private SendMessageRequest request(String text) {
        SendMessageRequest request = new SendMessageRequest();
        request.setClientMsgId(CLIENT_ID);
        request.setText(text);
        return request;
    }

    private ChatMessage message(Long seq) {
        ChatMessage message = new ChatMessage();
        message.setId(100L + seq);
        message.setConversationId(10L);
        message.setSenderId(1L);
        message.setClientMsgId(CLIENT_ID);
        message.setSeq(seq);
        message.setText("正文");
        message.setCreatedAt(LocalDateTime.parse("2026-09-17T10:00:00"));
        return message;
    }

    private void assertForbidden(Runnable action) {
        assertThatThrownBy(action::run).isInstanceOf(BusinessException.class).extracting("code").isEqualTo(403);
    }
}
