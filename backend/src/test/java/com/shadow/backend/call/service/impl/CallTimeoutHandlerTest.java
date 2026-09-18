package com.shadow.backend.call.service.impl;

import com.shadow.backend.call.config.LiveKitProperties;
import com.shadow.backend.call.constant.CallStatus;
import com.shadow.backend.call.entity.CallSession;
import com.shadow.backend.call.mapper.CallSessionMapper;
import com.shadow.backend.chat.entity.ChatConversation;
import com.shadow.backend.chat.entity.ChatMessage;
import com.shadow.backend.chat.entity.ChatOutbox;
import com.shadow.backend.chat.mapper.ChatConversationMapper;
import com.shadow.backend.chat.mapper.ChatMessageMapper;
import com.shadow.backend.chat.mapper.ChatOutboxMapper;
import com.shadow.backend.common.config.JacksonConfig;
import com.shadow.backend.user.mapper.UserMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class CallTimeoutHandlerTest {
    private static final String CALL_ID = "11111111-2222-4333-8444-555555555555";

    @Mock private CallSessionMapper callMapper;
    @Mock private ChatConversationMapper conversationMapper;
    @Mock private ChatMessageMapper messageMapper;
    @Mock private ChatOutboxMapper outboxMapper;
    @Mock private UserMapper userMapper;
    private CallTimeoutHandler handler;
    private JsonMapper jsonMapper;
    private ChatConversation conversation;

    @BeforeEach
    void setUp() {
        var builder = JsonMapper.builder();
        new JacksonConfig().jsonMapperBuilderCustomizer().customize(builder);
        jsonMapper = builder.build();
        LiveKitProperties properties = new LiveKitProperties();
        properties.setCallTimeoutSeconds(60);
        properties.setTimeoutBatchSize(100);
        handler = new CallTimeoutHandler(callMapper, properties,
                new CallEventComposer(outboxMapper, userMapper, jsonMapper),
                new CallChatRecorder(conversationMapper, messageMapper, outboxMapper, jsonMapper));
        conversation = new ChatConversation();
        conversation.setId(10L);
        conversation.setUserLowId(1L);
        conversation.setUserHighId(2L);
        conversation.setLastSeq(5L);
    }

    @Test
    void candidatesDelegateToDatabaseTimeQuery() {
        when(callMapper.findTimeoutCandidates(60, 100)).thenReturn(List.of(CALL_ID));
        assertThat(handler.candidates()).containsExactly(CALL_ID);
    }

    @Test
    void failedClaimDoesNotEmitAnything() {
        when(callMapper.markTimeout(CALL_ID, 60)).thenReturn(0);
        assertThat(handler.timeoutOne(CALL_ID)).isFalse();
        verify(callMapper, never()).selectByCallId(anyString());
        verify(messageMapper, never()).insert(any(ChatMessage.class));
        verify(outboxMapper, never()).insert(any(ChatOutbox.class));
    }

    @Test
    void successfulClaimEmitsTimeoutEventUsingDatabaseEndedAt() {
        when(callMapper.markTimeout(CALL_ID, 60)).thenReturn(1);
        when(callMapper.selectByCallId(CALL_ID)).thenReturn(call(CallStatus.TIMEOUT));
        when(conversationMapper.lockById(10L)).thenReturn(conversation);
        when(messageMapper.insert(any(ChatMessage.class))).thenAnswer(invocation -> {
            ((ChatMessage) invocation.getArgument(0)).setId(101L);
            return 1;
        });
        assertThat(handler.timeoutOne(CALL_ID)).isTrue();
        var rows = ArgumentCaptor.forClass(ChatOutbox.class);
        verify(outboxMapper, times(4)).insert(rows.capture());
        assertThat(rows.getAllValues()).extracting(ChatOutbox::getTopic)
                .containsExactly("chat/user/1/calls", "chat/user/2/calls",
                        "chat/user/1/events", "chat/user/2/events");
        JsonNode event = jsonMapper.readTree(rows.getAllValues().getFirst().getPayload());
        assertThat(event.get("eventType").asString()).isEqualTo("call.timeout");
        assertThat(event.get("version").asInt()).isEqualTo(1);
        assertThat(event.get("callId").asString()).isEqualTo(CALL_ID);
        assertThat(event.get("occurredAt").asString()).isEqualTo("2026-09-17T10:01:00Z");
        assertThat(event.get("payload").get("status").asInt()).isEqualTo(CallStatus.TIMEOUT.getValue());
        assertThat(event.get("payload").get("endReason").asString()).isEqualTo("timeout");
        assertThat(event.get("payload").has("token")).isTrue();
        assertThat(event.get("payload").get("token").isNull()).isTrue();
        JsonNode messageEvent = jsonMapper.readTree(rows.getAllValues().get(2).getPayload());
        assertThat(messageEvent.get("eventType").asString()).isEqualTo("message.created");
        assertThat(messageEvent.get("occurredAt").asString()).isEqualTo("2026-09-17T10:01:00Z");
        assertThat(messageEvent.get("payload").get("type").asString()).isEqualTo("CALL");
        assertThat(messageEvent.get("payload").get("text").asString()).isEqualTo("[语音通话] 未接听");
        var messages = ArgumentCaptor.forClass(ChatMessage.class);
        verify(messageMapper).insert(messages.capture());
        assertThat(messages.getValue().getSeq()).isEqualTo(6L);
        assertThat(conversation.getLastText()).isEqualTo("[语音通话] 未接听");
    }

    private CallSession call(CallStatus status) {
        CallSession call = new CallSession();
        call.setCallId(CALL_ID);
        call.setConversationId(10L);
        call.setCallerId(1L);
        call.setCalleeId(2L);
        call.setStatus(status.getValue());
        call.setMediaType("AUDIO");
        call.setEndReason("timeout");
        call.setCreatedAt(LocalDateTime.parse("2026-09-17T10:00:00"));
        call.setEndedAt(LocalDateTime.parse("2026-09-17T10:01:00"));
        return call;
    }
}
