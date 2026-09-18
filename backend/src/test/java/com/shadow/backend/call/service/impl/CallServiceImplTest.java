package com.shadow.backend.call.service.impl;

import com.shadow.backend.call.constant.CallStatus;
import com.shadow.backend.call.dto.InitiateCallRequest;
import com.shadow.backend.call.entity.CallSession;
import com.shadow.backend.call.mapper.CallSessionMapper;
import com.shadow.backend.call.service.LiveKitTokenService;
import com.shadow.backend.call.vo.CallCursorPageVO;
import com.shadow.backend.call.vo.CallVO;
import com.shadow.backend.chat.entity.ChatConversation;
import com.shadow.backend.chat.entity.ChatMessage;
import com.shadow.backend.chat.entity.ChatOutbox;
import com.shadow.backend.chat.mapper.ChatConversationMapper;
import com.shadow.backend.chat.mapper.ChatMessageMapper;
import com.shadow.backend.chat.mapper.ChatOutboxMapper;
import com.shadow.backend.common.config.JacksonConfig;
import com.shadow.backend.common.exception.BusinessException;
import com.shadow.backend.call.config.LiveKitProperties;
import com.shadow.backend.user.constant.AuditStatus;
import com.shadow.backend.user.entity.User;
import com.shadow.backend.user.mapper.UserMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.inOrder;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class CallServiceImplTest {
    private static final String CALL_ID = "11111111-2222-4333-8444-555555555555";

    @Mock private CallSessionMapper callMapper;
    @Mock private ChatConversationMapper conversationMapper;
    @Mock private ChatMessageMapper messageMapper;
    @Mock private ChatOutboxMapper outboxMapper;
    @Mock private UserMapper userMapper;
    @Mock private LiveKitTokenService tokenService;
    private LiveKitProperties liveKitProperties;
    private CallServiceImpl service;
    private JsonMapper jsonMapper;
    private ChatConversation conversation;

    @BeforeEach
    void setUp() {
        var builder = JsonMapper.builder();
        new JacksonConfig().jsonMapperBuilderCustomizer().customize(builder);
        jsonMapper = builder.build();
        liveKitProperties = new LiveKitProperties();
        liveKitProperties.setEnabled(true);
        liveKitProperties.setUrl("ws://localhost:7880");
        service = new CallServiceImpl(callMapper, conversationMapper, userMapper, tokenService,
                liveKitProperties, new CallEventComposer(outboxMapper, userMapper, jsonMapper),
                new CallChatRecorder(conversationMapper, messageMapper, outboxMapper, jsonMapper));
        conversation = new ChatConversation();
        conversation.setId(10L);
        conversation.setUserLowId(1L);
        conversation.setUserHighId(2L);
        conversation.setLastSeq(5L);
    }

    @Test
    void initiateRejectsInvalidArgumentsAndSelfCallBeforeDatabase() {
        assertThatThrownBy(() -> service.initiate(1L, null)).isInstanceOf(BusinessException.class);
        assertThatThrownBy(() -> service.initiate(1L, request(0L, "AUDIO"))).isInstanceOf(BusinessException.class);
        assertThatThrownBy(() -> service.initiate(1L, request(2L, "VOICE"))).isInstanceOf(BusinessException.class);
        assertThatThrownBy(() -> service.initiate(1L, request(1L, "AUDIO"))).isInstanceOf(BusinessException.class);
        verifyNoInteractions(userMapper, conversationMapper, callMapper, outboxMapper);
    }

    @Test
    void initiateRejectsInactiveUsers() {
        User rejected = user(2L);
        rejected.setAuditStatus(0);
        when(userMapper.selectById(1L)).thenReturn(user(1L));
        when(userMapper.selectById(2L)).thenReturn(rejected);
        assertForbidden(() -> service.initiate(1L, request(2L, "AUDIO")));
        verifyNoInteractions(conversationMapper, callMapper, outboxMapper);
    }

    @Test
    void initiateCreatesCallingSessionEmitsToBothAndTokenOnlyInResponse() {
        activeUsers();
        when(conversationMapper.lockPair(1L, 2L)).thenReturn(conversation);
        when(callMapper.findActiveByPair(1L, 2L)).thenReturn(null);
        when(callMapper.insert(any(CallSession.class))).thenAnswer(invocation -> {
            ((CallSession) invocation.getArgument(0)).setId(77L);
            return 1;
        });
        when(tokenService.issue(anyString(), anyLong(), anyString())).thenReturn("jwt-caller");
        when(tokenService.roomName(anyString())).thenAnswer(invocation -> "call_" + invocation.getArgument(0));
        CallVO vo = service.initiate(1L, request(2L, "AUDIO"));
        var order = inOrder(conversationMapper, callMapper, outboxMapper);
        order.verify(conversationMapper).createDirect(eq(1L), eq(2L), any());
        order.verify(conversationMapper).lockPair(1L, 2L);
        order.verify(callMapper).findActiveByPair(1L, 2L);
        order.verify(callMapper).insert(any(CallSession.class));
        order.verify(outboxMapper, times(2)).insert(any(ChatOutbox.class));
        assertThat(vo.getCallId()).isNotBlank();
        assertThat(vo.getStatus()).isEqualTo(CallStatus.CALLING.getValue());
        assertThat(vo.getConversationId()).isEqualTo(10L);
        assertThat(vo.getToken()).isEqualTo("jwt-caller");
        assertThat(vo.getRoomName()).isEqualTo("call_" + vo.getCallId());
        assertThat(vo.getLiveKitUrl()).isEqualTo("ws://localhost:7880");
        var rows = ArgumentCaptor.forClass(ChatOutbox.class);
        verify(outboxMapper, times(2)).insert(rows.capture());
        assertThat(rows.getAllValues()).extracting(ChatOutbox::getTopic)
                .containsExactly("chat/user/1/calls", "chat/user/2/calls");
        JsonNode event = jsonMapper.readTree(rows.getAllValues().getFirst().getPayload());
        assertThat(event.get("eventType").asString()).isEqualTo("call.created");
        assertThat(event.get("version").asInt()).isEqualTo(1);
        assertThat(event.get("callId").asString()).isEqualTo(vo.getCallId());
        assertThat(event.get("payload").get("status").asInt()).isEqualTo(CallStatus.CALLING.getValue());
        assertThat(event.get("payload").get("token").isNull()).isTrue();
        assertThat(event.get("payload").get("roomName").isNull()).isTrue();
        assertThat(event.get("payload").get("liveKitUrl").isNull()).isTrue();
    }

    @Test
    void initiateConflictsWhenPairAlreadyHasActiveCall() {
        activeUsers();
        when(conversationMapper.lockPair(1L, 2L)).thenReturn(conversation);
        when(callMapper.findActiveByPair(1L, 2L)).thenReturn(call(CallStatus.CALLING));
        assertThatThrownBy(() -> service.initiate(1L, request(2L, "AUDIO")))
                .isInstanceOf(BusinessException.class).extracting("code").isEqualTo(409);
        verify(callMapper, never()).insert(any(CallSession.class));
        verifyNoInteractions(outboxMapper);
    }

    @Test
    void initiateKeepsSignallingWhenLiveKitDisabled() {
        liveKitProperties.setEnabled(false);
        liveKitProperties.setUrl("");
        activeUsers();
        when(conversationMapper.lockPair(1L, 2L)).thenReturn(conversation);
        when(callMapper.findActiveByPair(1L, 2L)).thenReturn(null);
        when(callMapper.insert(any(CallSession.class))).thenAnswer(invocation -> {
            ((CallSession) invocation.getArgument(0)).setId(77L);
            return 1;
        });
        CallVO vo = service.initiate(1L, request(2L, "AUDIO"));
        assertThat(vo.getStatus()).isEqualTo(CallStatus.CALLING.getValue());
        assertThat(vo.getRoomName()).isNull();
        assertThat(vo.getLiveKitUrl()).isNull();
        assertThat(vo.getToken()).isNull();
        verify(tokenService, never()).issue(anyString(), anyLong(), any());
        verify(tokenService, never()).roomName(anyString());
        verify(outboxMapper, times(2)).insert(any(ChatOutbox.class));
    }

    @Test
    void acceptMovesCallingToInCallAndEmitsAccepted() {
        when(callMapper.lockByCallId(CALL_ID)).thenReturn(call(CallStatus.CALLING));
        when(userMapper.selectById(1L)).thenReturn(user(1L));
        when(userMapper.selectById(2L)).thenReturn(user(2L));
        when(tokenService.issue(anyString(), anyLong(), anyString())).thenReturn("jwt-callee");
        CallVO vo = service.accept(2L, CALL_ID);
        assertThat(vo.getStatus()).isEqualTo(CallStatus.IN_CALL.getValue());
        assertThat(vo.getToken()).isEqualTo("jwt-callee");
        var rows = ArgumentCaptor.forClass(ChatOutbox.class);
        verify(outboxMapper, times(2)).insert(rows.capture());
        JsonNode event = jsonMapper.readTree(rows.getAllValues().getFirst().getPayload());
        assertThat(event.get("eventType").asString()).isEqualTo("call.accepted");
        assertThat(event.get("payload").get("status").asInt()).isEqualTo(CallStatus.IN_CALL.getValue());
    }

    @ParameterizedTest
    @ValueSource(ints = {1, 2, 5})
    void acceptIsIdempotentAfterTransitionOrTerminal(int status) {
        CallSession ended = call(CallStatus.fromValue(status));
        ended.setAcceptedAt(LocalDateTime.parse("2026-09-17T10:00:30"));
        when(callMapper.lockByCallId(CALL_ID)).thenReturn(ended);
        when(userMapper.selectById(2L)).thenReturn(user(2L));
        CallVO vo = service.accept(2L, CALL_ID);
        assertThat(vo.getStatus()).isEqualTo(status);
        verify(callMapper, never()).updateById(any(CallSession.class));
        verifyNoInteractions(outboxMapper);
    }

    @Test
    void callerCannotAcceptOrRejectAndCalleeCannotCancel() {
        when(callMapper.lockByCallId(CALL_ID)).thenReturn(call(CallStatus.CALLING));
        assertForbidden(() -> service.accept(1L, CALL_ID));
        assertForbidden(() -> service.reject(1L, CALL_ID));
        assertForbidden(() -> service.cancel(2L, CALL_ID));
        verify(callMapper, never()).updateById(any(CallSession.class));
        verifyNoInteractions(outboxMapper);
    }

    @ParameterizedTest
    @ValueSource(ints = {2, 3, 4, 5})
    void rejectAndCancelAreIdempotentOnTerminalStates(int status) {
        when(callMapper.lockByCallId(CALL_ID)).thenReturn(call(CallStatus.fromValue(status)));
        when(userMapper.selectById(1L)).thenReturn(user(1L));
        when(userMapper.selectById(2L)).thenReturn(user(2L));
        assertThat(service.reject(2L, CALL_ID).getStatus()).isEqualTo(status);
        assertThat(service.cancel(1L, CALL_ID).getStatus()).isEqualTo(status);
        verify(callMapper, never()).updateById(any(CallSession.class));
        verifyNoInteractions(outboxMapper);
    }

    @Test
    void rejectEndsCallingWithRejectedEvent() {
        when(callMapper.lockByCallId(CALL_ID)).thenReturn(call(CallStatus.CALLING));
        when(userMapper.selectById(1L)).thenReturn(user(1L));
        when(userMapper.selectById(2L)).thenReturn(user(2L));
        stubCallRecordWrite();
        CallVO vo = service.reject(2L, CALL_ID);
        assertThat(vo.getStatus()).isEqualTo(CallStatus.REJECTED.getValue());
        assertThat(vo.getEndReason()).isEqualTo("rejected");
        assertThat(vo.getToken()).isNull();
        verify(tokenService, never()).issue(anyString(), anyLong(), any());
        var rows = ArgumentCaptor.forClass(ChatOutbox.class);
        verify(outboxMapper, times(4)).insert(rows.capture());
        assertThat(rows.getAllValues()).extracting(ChatOutbox::getTopic)
                .containsExactly("chat/user/1/calls", "chat/user/2/calls",
                        "chat/user/1/events", "chat/user/2/events");
        JsonNode event = jsonMapper.readTree(rows.getAllValues().getFirst().getPayload());
        assertThat(event.get("eventType").asString()).isEqualTo("call.rejected");
        assertThat(event.get("payload").get("endReason").asString()).isEqualTo("rejected");
        JsonNode messageEvent = jsonMapper.readTree(rows.getAllValues().get(2).getPayload());
        assertThat(messageEvent.get("eventType").asString()).isEqualTo("message.created");
        assertThat(messageEvent.get("messageId").asString()).isEqualTo("101");
        assertThat(messageEvent.get("payload").get("type").asString()).isEqualTo("CALL");
        assertThat(messageEvent.get("payload").get("callId").asString()).isEqualTo(CALL_ID);
        assertThat(messageEvent.get("payload").get("text").asString()).isEqualTo("[语音通话] 已拒绝");
        var messages = ArgumentCaptor.forClass(ChatMessage.class);
        verify(messageMapper).insert(messages.capture());
        assertThat(messages.getValue().getSeq()).isEqualTo(6L);
        assertThat(conversation.getLastSeq()).isEqualTo(6L);
        assertThat(conversation.getLastText()).isEqualTo("[语音通话] 已拒绝");
    }

    @Test
    void cancelEndsCallingWithCancelledEvent() {
        when(callMapper.lockByCallId(CALL_ID)).thenReturn(call(CallStatus.CALLING));
        when(userMapper.selectById(1L)).thenReturn(user(1L));
        when(userMapper.selectById(2L)).thenReturn(user(2L));
        stubCallRecordWrite();
        assertThat(service.cancel(1L, CALL_ID).getEndReason()).isEqualTo("cancelled");
        var rows = ArgumentCaptor.forClass(ChatOutbox.class);
        verify(outboxMapper, times(4)).insert(rows.capture());
        assertThat(jsonMapper.readTree(rows.getAllValues().getFirst().getPayload())
                .get("eventType").asString()).isEqualTo("call.cancelled");
        assertThat(jsonMapper.readTree(rows.getAllValues().get(2).getPayload())
                .get("payload").get("text").asString()).isEqualTo("[语音通话] 已取消");
    }

    @Test
    void rejectAndCancelConflictWhileInCall() {
        when(callMapper.lockByCallId(CALL_ID)).thenReturn(call(CallStatus.IN_CALL));
        assertThatThrownBy(() -> service.reject(2L, CALL_ID))
                .isInstanceOf(BusinessException.class).extracting("code").isEqualTo(409);
        assertThatThrownBy(() -> service.cancel(1L, CALL_ID))
                .isInstanceOf(BusinessException.class).extracting("code").isEqualTo(409);
        verifyNoInteractions(outboxMapper);
    }

    @ParameterizedTest
    @ValueSource(longs = {1, 2})
    void eitherPartyCanEndInCall(long userId) {
        CallSession inCall = call(CallStatus.IN_CALL);
        inCall.setAcceptedAt(LocalDateTime.parse("2026-09-17T10:00:30"));
        when(callMapper.lockByCallId(CALL_ID)).thenReturn(inCall);
        activeUsers();
        stubCallRecordWrite();
        CallVO vo = service.end(userId, CALL_ID);
        assertThat(vo.getStatus()).isEqualTo(CallStatus.ENDED.getValue());
        assertThat(vo.getEndReason()).isEqualTo("hangup");
        assertThat(vo.getDurationSeconds()).isNotNull();
        verify(outboxMapper, times(4)).insert(any(ChatOutbox.class));
        var messages = ArgumentCaptor.forClass(ChatMessage.class);
        verify(messageMapper).insert(messages.capture());
        assertThat(messages.getValue().getText()).startsWith("[语音通话] 通话时长 ");
    }

    @Test
    void endConflictsWhileCallingAndIsIdempotentAfterEnd() {
        when(callMapper.lockByCallId(CALL_ID)).thenReturn(call(CallStatus.CALLING));
        when(userMapper.selectById(1L)).thenReturn(user(1L));
        assertThatThrownBy(() -> service.end(1L, CALL_ID))
                .isInstanceOf(BusinessException.class).extracting("code").isEqualTo(409);
        when(callMapper.lockByCallId(CALL_ID)).thenReturn(call(CallStatus.ENDED));
        assertThat(service.end(1L, CALL_ID).getStatus()).isEqualTo(CallStatus.ENDED.getValue());
        verify(callMapper, never()).updateById(any(CallSession.class));
        verifyNoInteractions(outboxMapper);
    }

    @Test
    void nonMemberAndUnknownCallShareSameError() {
        when(callMapper.lockByCallId(CALL_ID)).thenReturn(call(CallStatus.CALLING));
        assertForbidden(() -> service.accept(3L, CALL_ID));
        when(callMapper.lockByCallId("missing")).thenReturn(null);
        assertForbidden(() -> service.accept(2L, "missing"));
        verifyNoInteractions(outboxMapper, tokenService);
    }

    @Test
    void activeCallReturnsLatestOrNull() {
        when(userMapper.selectById(1L)).thenReturn(user(1L));
        when(callMapper.findActiveByUser(1L)).thenReturn(call(CallStatus.CALLING));
        assertThat(service.activeCall(1L).getStatus()).isEqualTo(CallStatus.CALLING.getValue());
        when(callMapper.findActiveByUser(1L)).thenReturn(null);
        assertThat(service.activeCall(1L)).isNull();
    }

    @Test
    void recordsUseLimitPlusOneCursorAndRejectInvalidPaging() {
        when(userMapper.selectById(1L)).thenReturn(user(1L));
        when(callMapper.findPageByUser(1L, null, 3)).thenReturn(List.of(
                call(CallStatus.ENDED), call(CallStatus.TIMEOUT), call(CallStatus.REJECTED)));
        CallCursorPageVO<CallVO> page = service.records(1L, null, 2);
        assertThat(page.getItems()).extracting(CallVO::getStatus)
                .containsExactly(CallStatus.ENDED.getValue(), CallStatus.TIMEOUT.getValue());
        assertThat(page.isHasMore()).isTrue();
        assertThat(page.getNextCursor()).isEqualTo(77L);
        assertThatThrownBy(() -> service.records(1L, 0L, 50)).isInstanceOf(BusinessException.class);
        assertThatThrownBy(() -> service.records(1L, null, 101)).isInstanceOf(BusinessException.class);
    }

    @Test
    void roomFinishedOnlyEndsInCallAndIgnoresOthers() {
        when(callMapper.lockByCallId(CALL_ID)).thenReturn(null);
        service.onRoomFinished(CALL_ID);
        when(callMapper.lockByCallId(CALL_ID)).thenReturn(call(CallStatus.CALLING));
        service.onRoomFinished(CALL_ID);
        when(callMapper.lockByCallId(CALL_ID)).thenReturn(call(CallStatus.ENDED));
        service.onRoomFinished(CALL_ID);
        verify(callMapper, never()).updateById(any(CallSession.class));
        verifyNoInteractions(outboxMapper);

        CallSession inCall = call(CallStatus.IN_CALL);
        inCall.setAcceptedAt(LocalDateTime.parse("2026-09-17T10:00:30"));
        when(callMapper.lockByCallId(CALL_ID)).thenReturn(inCall);
        when(userMapper.selectById(1L)).thenReturn(user(1L));
        when(userMapper.selectById(2L)).thenReturn(user(2L));
        stubCallRecordWrite();
        service.onRoomFinished(CALL_ID);
        assertThat(inCall.getStatus()).isEqualTo(CallStatus.ENDED.getValue());
        assertThat(inCall.getEndReason()).isEqualTo("room_finished");
        verify(outboxMapper, times(4)).insert(any(ChatOutbox.class));
    }

    private void activeUsers() {
        when(userMapper.selectById(1L)).thenReturn(user(1L));
        when(userMapper.selectById(2L)).thenReturn(user(2L));
    }

    private void stubCallRecordWrite() {
        when(conversationMapper.lockById(10L)).thenReturn(conversation);
        when(messageMapper.insert(any(ChatMessage.class))).thenAnswer(invocation -> {
            ((ChatMessage) invocation.getArgument(0)).setId(101L);
            return 1;
        });
    }

    private User user(Long id) {
        User user = new User();
        user.setId(id);
        user.setStatus(1);
        user.setAuditStatus(AuditStatus.APPROVED.getValue());
        user.setDeleted(0);
        user.setNickname("昵称" + id);
        return user;
    }

    private InitiateCallRequest request(Long calleeId, String mediaType) {
        InitiateCallRequest request = new InitiateCallRequest();
        request.setCalleeId(calleeId);
        request.setMediaType(mediaType);
        return request;
    }

    private CallSession call(CallStatus status) {
        CallSession call = new CallSession();
        call.setId(77L);
        call.setCallId(CALL_ID);
        call.setConversationId(10L);
        call.setCallerId(1L);
        call.setCalleeId(2L);
        call.setStatus(status.getValue());
        call.setMediaType("AUDIO");
        call.setCreatedAt(LocalDateTime.parse("2026-09-17T10:00:00"));
        return call;
    }

    private void assertForbidden(Runnable action) {
        assertThatThrownBy(action::run).isInstanceOf(BusinessException.class).extracting("code").isEqualTo(403);
    }
}
