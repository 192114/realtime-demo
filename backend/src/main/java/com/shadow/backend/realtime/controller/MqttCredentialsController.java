package com.shadow.backend.realtime.controller;

import com.shadow.backend.common.response.Result;
import com.shadow.backend.realtime.dto.MqttCredentialsRequest;
import com.shadow.backend.realtime.service.MqttCredentialsService;
import com.shadow.backend.realtime.vo.MqttCredentialsVO;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/app/realtime")
@RequiredArgsConstructor
public class MqttCredentialsController {
    private final MqttCredentialsService credentialsService;

    @PostMapping("/mqtt-credentials")
    public Result<MqttCredentialsVO> credentials(@Valid @RequestBody MqttCredentialsRequest request,
                                               HttpServletResponse response) {
        response.setHeader("Cache-Control", "no-store");
        response.setHeader("Pragma", "no-cache");
        return Result.success(credentialsService.issue(request));
    }
}
