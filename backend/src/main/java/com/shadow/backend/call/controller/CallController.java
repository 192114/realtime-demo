package com.shadow.backend.call.controller;

import com.shadow.backend.call.dto.InitiateCallRequest;
import com.shadow.backend.call.service.CallService;
import com.shadow.backend.call.vo.CallCursorPageVO;
import com.shadow.backend.call.vo.CallVO;
import com.shadow.backend.common.response.Result;
import com.shadow.backend.common.util.LoginUserUtil;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/app/call")
public class CallController {
    private final CallService callService;

    @PostMapping("/direct")
    public Result<CallVO> initiate(@Valid @RequestBody InitiateCallRequest request) {
        return Result.success(callService.initiate(LoginUserUtil.currentUserId(), request));
    }

    @PostMapping("/{callId}/accept")
    public Result<CallVO> accept(@PathVariable String callId) {
        return Result.success(callService.accept(LoginUserUtil.currentUserId(), callId));
    }

    @PostMapping("/{callId}/reject")
    public Result<CallVO> reject(@PathVariable String callId) {
        return Result.success(callService.reject(LoginUserUtil.currentUserId(), callId));
    }

    @PostMapping("/{callId}/cancel")
    public Result<CallVO> cancel(@PathVariable String callId) {
        return Result.success(callService.cancel(LoginUserUtil.currentUserId(), callId));
    }

    @PostMapping("/{callId}/end")
    public Result<CallVO> end(@PathVariable String callId) {
        return Result.success(callService.end(LoginUserUtil.currentUserId(), callId));
    }

    @GetMapping("/active")
    public Result<CallVO> active() {
        return Result.success(callService.activeCall(LoginUserUtil.currentUserId()));
    }

    @GetMapping("/records")
    public Result<CallCursorPageVO<CallVO>> records(
            @RequestParam(required = false) Long beforeId, @RequestParam(defaultValue = "50") int limit) {
        return Result.success(callService.records(LoginUserUtil.currentUserId(), beforeId, limit));
    }
}
