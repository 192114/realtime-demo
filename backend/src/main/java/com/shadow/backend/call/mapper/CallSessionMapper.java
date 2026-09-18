package com.shadow.backend.call.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.shadow.backend.call.entity.CallSession;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

@Mapper
public interface CallSessionMapper extends BaseMapper<CallSession> {
    @Select("SELECT * FROM call_session WHERE call_id = #{callId} FOR UPDATE")
    CallSession lockByCallId(@Param("callId") String callId);

    @Select("SELECT * FROM call_session WHERE call_id = #{callId}")
    CallSession selectByCallId(@Param("callId") String callId);

    @Select("""
            SELECT * FROM call_session WHERE status IN (0, 1)
                AND ((caller_id = #{a} AND callee_id = #{b}) OR (caller_id = #{b} AND callee_id = #{a}))
            LIMIT 1
            """)
    CallSession findActiveByPair(@Param("a") Long a, @Param("b") Long b);

    @Select("""
            SELECT * FROM call_session WHERE status IN (0, 1)
                AND (caller_id = #{userId} OR callee_id = #{userId})
            ORDER BY id DESC LIMIT 1
            """)
    CallSession findActiveByUser(@Param("userId") Long userId);

    // 超时判定使用数据库时间，跨实例无需依赖应用时钟同步。
    @Select("""
            SELECT call_id FROM call_session WHERE status = 0
                AND created_at < TIMESTAMPADD(SECOND, -#{timeoutSeconds}, UTC_TIMESTAMP(6))
            ORDER BY id LIMIT #{limit}
            """)
    List<String> findTimeoutCandidates(@Param("timeoutSeconds") int timeoutSeconds, @Param("limit") int limit);

    // 条件更新与 Outbox claim 同风格：抢占成功才允许写事件，天然幂等。
    @Update("""
            UPDATE call_session SET status = 4, end_reason = 'timeout', ended_at = UTC_TIMESTAMP(6)
            WHERE call_id = #{callId} AND status = 0
                AND created_at < TIMESTAMPADD(SECOND, -#{timeoutSeconds}, UTC_TIMESTAMP(6))
            """)
    int markTimeout(@Param("callId") String callId, @Param("timeoutSeconds") int timeoutSeconds);

    @Select("""
            SELECT * FROM call_session WHERE (caller_id = #{userId} OR callee_id = #{userId})
                AND (#{beforeId} IS NULL OR id < #{beforeId})
            ORDER BY id DESC LIMIT #{limit}
            """)
    List<CallSession> findPageByUser(@Param("userId") Long userId, @Param("beforeId") Long beforeId,
                                     @Param("limit") int limit);
}
