package com.shadow.backend.realtime.service.impl;

import com.shadow.backend.common.util.StpAppUtil;
import com.shadow.backend.realtime.security.RealtimeSecrets;
import com.shadow.backend.realtime.service.RealtimeIdentityService;
import com.shadow.backend.user.constant.AuditStatus;
import com.shadow.backend.user.entity.User;
import com.shadow.backend.user.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class RealtimeIdentityServiceImpl implements RealtimeIdentityService {
    private final UserMapper userMapper;

    @Override
    public boolean isAccountEligible(long userId) {
        if (userId <= 0) {
            return false;
        }
        User user = userMapper.selectById(userId);
        return user != null && Long.valueOf(userId).equals(user.getId())
                && Integer.valueOf(0).equals(user.getDeleted())
                && Integer.valueOf(1).equals(user.getStatus())
                && Integer.valueOf(AuditStatus.APPROVED.getValue()).equals(user.getAuditStatus());
    }

    @Override
    public boolean isLoginValid(long userId, String loginTokenDigest) {
        // 从 Sa-Token 自身会话枚举当前 token，模块 Redis 不保存原始登录 token。
        return StpAppUtil.stpLogic.getTokenValueListByLoginId(userId).stream()
                .filter(token -> RealtimeSecrets.matches(loginTokenDigest, token))
                .anyMatch(token -> remainingLoginSeconds(userId, token) > 0);
    }

    @Override
    public long remainingLoginSeconds(long userId, String token) {
        if (token == null || token.isBlank()) {
            return 0;
        }
        Object loginId = StpAppUtil.stpLogic.getLoginIdByToken(token);
        if (loginId == null || !Long.toString(userId).equals(loginId.toString())) {
            return 0;
        }
        long absolute = StpAppUtil.stpLogic.getTokenTimeout(token);
        long active = StpAppUtil.stpLogic.getTokenActiveTimeoutByToken(token);
        return Math.min(normalizeTimeout(absolute), normalizeTimeout(active));
    }

    private long normalizeTimeout(long timeout) {
        return timeout == -1 ? Long.MAX_VALUE : Math.max(0, timeout);
    }
}
