package com.shadow.backend.chat.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.shadow.backend.chat.entity.ChatOutbox;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

@Mapper
public interface ChatOutboxMapper extends BaseMapper<ChatOutbox> {
    @Select("""
            SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE()
                AND table_name IN ('chat_conversation', 'chat_message', 'chat_outbox') AND engine = 'InnoDB'
            """)
    int countReadyTables();

    @Select("""
            SELECT id FROM chat_outbox WHERE delivered_at IS NULL AND next_attempt_at <= UTC_TIMESTAMP(6)
                AND (lease_until IS NULL OR lease_until <= UTC_TIMESTAMP(6))
            ORDER BY next_attempt_at, id LIMIT #{limit}
            """)
    List<Long> findCandidates(@Param("limit") int limit);

    // 原子条件抢占：使用数据库时间，跨实例无需依赖应用时钟同步。
    @Update("""
            UPDATE chat_outbox SET claim_token = #{token},
                lease_until = TIMESTAMPADD(SECOND, #{leaseSeconds}, UTC_TIMESTAMP(6)),
                attempts = LEAST(attempts + 1, 2147483647)
            WHERE id = #{id} AND delivered_at IS NULL AND next_attempt_at <= UTC_TIMESTAMP(6)
                AND (lease_until IS NULL OR lease_until <= UTC_TIMESTAMP(6))
            """)
    int claim(@Param("id") Long id, @Param("token") String token, @Param("leaseSeconds") int leaseSeconds);

    @Select("""
            SELECT * FROM chat_outbox WHERE id = #{id} AND claim_token = #{token}
                AND delivered_at IS NULL AND lease_until > UTC_TIMESTAMP(6)
            """)
    ChatOutbox findClaim(@Param("id") Long id, @Param("token") String token);

    @Update("""
            UPDATE chat_outbox SET delivered_at = UTC_TIMESTAMP(6), claim_token = NULL, lease_until = NULL
            WHERE id = #{id} AND claim_token = #{token} AND delivered_at IS NULL
                AND lease_until > UTC_TIMESTAMP(6)
            """)
    int acknowledge(@Param("id") Long id, @Param("token") String token);

    // 保留错误类型和尝试次数，不存储可能含消息、凭证等信息的异常 message 或堆栈。
    @Update("""
            UPDATE chat_outbox SET claim_token = NULL, lease_until = NULL, last_error = #{error},
                next_attempt_at = TIMESTAMPADD(SECOND, #{delaySeconds}, UTC_TIMESTAMP(6))
            WHERE id = #{id} AND claim_token = #{token} AND delivered_at IS NULL
                AND lease_until > UTC_TIMESTAMP(6)
            """)
    int retry(@Param("id") Long id, @Param("token") String token, @Param("delaySeconds") long delaySeconds,
              @Param("error") String error);
}
