package com.shadow.backend.realtime.service.impl;

import cn.dev33.satoken.stp.StpLogic;
import com.shadow.backend.common.util.StpAppUtil;
import com.shadow.backend.realtime.security.RealtimeSecrets;
import com.shadow.backend.user.entity.User;
import com.shadow.backend.user.mapper.UserMapper;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.*;

class RealtimeIdentityServiceImplTest {
    private final UserMapper mapper = mock(UserMapper.class);
    private final RealtimeIdentityServiceImpl service = new RealtimeIdentityServiceImpl(mapper);

    @Test
    void accountEligibility_requeriesAndRejectsDeletedDisabledPendingRejectedAndMissing() {
        User user = new User();
        user.setId(42L);
        user.setStatus(1);
        user.setDeleted(0);
        user.setAuditStatus(1);
        when(mapper.selectById(42L)).thenReturn(user);
        assertThat(service.isAccountEligible(42)).isTrue();
        user.setDeleted(1);
        assertThat(service.isAccountEligible(42)).isFalse();
        user.setDeleted(0);
        user.setStatus(0);
        assertThat(service.isAccountEligible(42)).isFalse();
        user.setStatus(1);
        for (Integer status : new Integer[]{0, 2, null}) {
            user.setAuditStatus(status);
            assertThat(service.isAccountEligible(42)).isFalse();
        }
        when(mapper.selectById(42L)).thenReturn(null);
        assertThat(service.isAccountEligible(42)).isFalse();
        assertThat(service.isAccountEligible(0)).isFalse();
    }

    @Test
    void loginBinding_checksExactTokenOwnerRevocationAbsoluteAndIdleExpiry() {
        StpLogic original = StpAppUtil.stpLogic;
        StpLogic app = mock(StpLogic.class);
        StpAppUtil.stpLogic = app;
        try {
            when(app.getTokenValueListByLoginId(42L)).thenReturn(List.of("other-device-token", "bound-token"));
            when(app.getLoginIdByToken("bound-token")).thenReturn("42");
            when(app.getTokenTimeout("bound-token")).thenReturn(120L);
            when(app.getTokenActiveTimeoutByToken("bound-token")).thenReturn(-1L);
            String digest = RealtimeSecrets.sha256("bound-token");
            assertThat(service.isLoginValid(42, digest)).isTrue();
            assertThat(service.isLoginValid(42, RealtimeSecrets.sha256("unknown"))).isFalse();
            when(app.getLoginIdByToken("bound-token")).thenReturn(null);
            assertThat(service.isLoginValid(42, digest)).isFalse();
            when(app.getLoginIdByToken("bound-token")).thenReturn("43");
            assertThat(service.isLoginValid(42, digest)).isFalse();
            when(app.getLoginIdByToken("bound-token")).thenReturn("42");
            when(app.getTokenTimeout("bound-token")).thenReturn(0L);
            assertThat(service.isLoginValid(42, digest)).isFalse();
            when(app.getTokenTimeout("bound-token")).thenReturn(-1L);
            when(app.getTokenActiveTimeoutByToken("bound-token")).thenReturn(-2L);
            assertThat(service.isLoginValid(42, digest)).isFalse();
            when(app.getTokenActiveTimeoutByToken("bound-token")).thenReturn(30L);
            assertThat(service.remainingLoginSeconds(42, "bound-token")).isEqualTo(30);
            when(app.getTokenValueListByLoginId(42L)).thenReturn(List.of());
            assertThat(service.isLoginValid(42, digest)).isFalse();
        } finally {
            StpAppUtil.stpLogic = original;
        }
    }
}
