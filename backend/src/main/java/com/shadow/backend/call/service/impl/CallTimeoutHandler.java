package com.shadow.backend.call.service.impl;

import com.shadow.backend.call.config.LiveKitProperties;
import com.shadow.backend.call.entity.CallSession;
import com.shadow.backend.call.mapper.CallSessionMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 呼叫超时由数据库时间判定的条件更新驱动：抢占成功才写事件，天然幂等且无应用时钟依赖。
 * 调度器逐条跨 Bean 调用，使每条超时处理拥有独立事务。
 */
@Service
@RequiredArgsConstructor
public class CallTimeoutHandler {
    private final CallSessionMapper callMapper;
    private final LiveKitProperties properties;
    private final CallEventComposer composer;
    private final CallChatRecorder recorder;

    @Transactional(readOnly = true)
    public List<String> candidates() {
        return callMapper.findTimeoutCandidates(properties.getCallTimeoutSeconds(), properties.getTimeoutBatchSize());
    }

    @Transactional
    public boolean timeoutOne(String callId) {
        if (callMapper.markTimeout(callId, properties.getCallTimeoutSeconds()) != 1) {
            return false;
        }
        CallSession call = callMapper.selectByCallId(callId);
        if (call != null) {
            // ended_at 由数据库写入，直接作为事件发生时间，保持与库内时间一致。
            composer.emit(call, "call.timeout", call.getEndedAt());
            recorder.record(call, call.getEndedAt());
        }
        return true;
    }
}
