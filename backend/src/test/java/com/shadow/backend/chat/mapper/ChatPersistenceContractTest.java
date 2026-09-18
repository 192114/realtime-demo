package com.shadow.backend.chat.mapper;

import org.apache.ibatis.session.Configuration;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.core.io.ClassPathResource;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

class ChatPersistenceContractTest {
    private Configuration configuration;

    @BeforeEach
    void setUp() {
        // 解析实际 Mapper SQL，但不冒充真实 MySQL 的并发及锁行为测试。
        configuration = new Configuration();
        configuration.addMapper(ChatConversationMapper.class);
        configuration.addMapper(ChatMessageMapper.class);
        configuration.addMapper(ChatOutboxMapper.class);
    }

    @Test
    void conversationAndIdempotencyBothUseCurrentLockingRead() {
        assertThat(sql(ChatConversationMapper.class, "lockById", Map.of("id", 1L)))
                .endsWith("FOR UPDATE");
        assertThat(sql(ChatConversationMapper.class, "lockPair", Map.of("low", 1L, "high", 2L)))
                .contains("user_low_id = ? AND user_high_id = ?").endsWith("FOR UPDATE");
        assertThat(sql(ChatMessageMapper.class, "findIdempotent",
                Map.of("conversationId", 1L, "senderId", 2L, "clientMsgId", "uuid")))
                .contains("conversation_id = ? AND sender_id = ? AND client_msg_id = ?").endsWith("FOR UPDATE");
    }

    @Test
    void historyAndSyncHaveExclusiveCursorAndOppositeOrder() {
        Map<String, Object> parameters = new HashMap<>();
        parameters.put("conversationId", 1L);
        parameters.put("beforeSeq", null);
        parameters.put("limit", 51);
        assertThat(sql(ChatMessageMapper.class, "history", parameters)).doesNotContain("seq <")
                .endsWith("ORDER BY seq DESC LIMIT ?");
        parameters.put("beforeSeq", 9L);
        assertThat(sql(ChatMessageMapper.class, "history", parameters)).contains("seq < ?");
        assertThat(sql(ChatMessageMapper.class, "sync", Map.of("conversationId", 1L, "afterSeq", 0L, "limit", 101)))
                .contains("seq > ?").endsWith("ORDER BY seq ASC LIMIT ?");
    }

    @Test
    void unreadFiltersPeerAndListFiltersMembershipAndEffectivePeer() {
        assertThat(sql(ChatMessageMapper.class, "countUnread",
                Map.of("conversationId", 1L, "peerId", 2L, "readSeq", 3L)))
                .contains("sender_id = ? AND seq > ?");
        Map<String, Object> parameters = new HashMap<>(Map.of("userId", 1L, "approved", 1, "limit", 51));
        parameters.put("beforeId", null);
        assertThat(sql(ChatConversationMapper.class, "findPage", parameters))
                .contains("c.user_low_id = ? OR c.user_high_id = ?")
                .contains("p.deleted = 0 AND p.status = 1 AND p.audit_status = ?")
                .doesNotContain("c.id <").endsWith("ORDER BY c.id DESC LIMIT ?");
        parameters.put("beforeId", 10L);
        assertThat(sql(ChatConversationMapper.class, "findPage", parameters)).contains("c.id < ?");
    }

    @Test
    void leaseRecoveryUsesDatabaseTimeAndExpiredWorkersCannotWrite() {
        assertThat(sql(ChatOutboxMapper.class, "findCandidates", Map.of("limit", 50)))
                .contains("delivered_at IS NULL", "next_attempt_at <= UTC_TIMESTAMP(6)",
                        "lease_until IS NULL OR lease_until <= UTC_TIMESTAMP(6)");
        assertThat(sql(ChatOutboxMapper.class, "claim", Map.of("id", 1L, "token", "uuid", "leaseSeconds", 60)))
                .contains("claim_token = ?", "TIMESTAMPADD(SECOND, ?, UTC_TIMESTAMP(6))",
                        "delivered_at IS NULL", "next_attempt_at <= UTC_TIMESTAMP(6)",
                        "lease_until IS NULL OR lease_until <= UTC_TIMESTAMP(6)");
        for (String method : new String[]{"findClaim", "acknowledge", "retry"}) {
            assertThat(sql(ChatOutboxMapper.class, method,
                    Map.of("id", 1L, "token", "uuid", "error", "IOException", "delaySeconds", 2)))
                    .contains("id = ? AND claim_token = ?", "delivered_at IS NULL", "lease_until > UTC_TIMESTAMP(6)");
        }
    }

    @Test
    void manualMigrationMatchesBaselineAndPreservesUniqueAndTransactionalConstraints() throws IOException {
        String start = "CREATE TABLE IF NOT EXISTS chat_conversation (";
        String migration = resource("sql/chat_migration.sql");
        String baseline = resource("sql/schema.sql");
        assertThat(migration.substring(migration.indexOf(start)).trim())
                .isEqualTo(baseline.substring(baseline.indexOf(start)).trim());
        assertThat(migration).doesNotContain("DROP TABLE", "TRUNCATE", "DELETE FROM");
        assertThat(migration).contains("UNIQUE KEY uk_chat_pair (user_low_id, user_high_id)",
                "UNIQUE KEY uk_chat_message_seq (conversation_id, seq)",
                "UNIQUE KEY uk_chat_message_client (conversation_id, sender_id, client_msg_id)",
                "VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL",
                "UNIQUE KEY uk_chat_claim_token (claim_token)",
                "UNIQUE KEY uk_chat_event_recipient (event_id, recipient_id)",
                "low_read_seq <= last_seq AND high_read_seq <= last_seq");
        assertThat(migration.split("ENGINE=InnoDB", -1)).hasSize(4);
    }

    private String sql(Class<?> mapper, String method, Map<String, ?> parameters) {
        return configuration.getMappedStatement(mapper.getName() + "." + method).getBoundSql(parameters)
                .getSql().replaceAll("\\s+", " ").trim();
    }

    private String resource(String name) throws IOException {
        return new ClassPathResource(name).getContentAsString(StandardCharsets.UTF_8);
    }
}
