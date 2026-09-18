package com.shadow.backend.realtime.response;

import cn.dev33.satoken.exception.NotLoginException;
import com.shadow.backend.common.exception.BusinessException;
import com.shadow.backend.common.response.Result;
import com.shadow.backend.realtime.controller.EmqxCallbackController;
import com.shadow.backend.realtime.controller.MqttCredentialsController;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.http.CacheControl;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.OptionalLong;

@Order(Ordered.HIGHEST_PRECEDENCE)
@RestControllerAdvice(assignableTypes = {EmqxCallbackController.class, MqttCredentialsController.class})
public class RealtimeExceptionHandler {
    @ExceptionHandler(Exception.class)
    public ResponseEntity<?> handle(Exception exception, HttpServletRequest request) {
        if (request.getRequestURI().startsWith("/internal/realtime/emqx/")) {
            return request.getRequestURI().endsWith("/authenticate")
                    ? EmqxProtocol.authentication(OptionalLong.empty()) : EmqxProtocol.authorization(false);
        }
        // 不使用异常消息，解析失败可能带入请求正文或凭据；也不向全局异常日志传播。
        if (exception instanceof NotLoginException) {
            return failure(401, 401, "请先登录");
        }
        if (exception instanceof MethodArgumentNotValidException || exception instanceof HttpMessageNotReadableException) {
            return failure(400, 400, "实时凭据请求参数无效");
        }
        if (exception instanceof BusinessException businessException) {
            return failure(200, businessException.getCode(), "实时凭据申请失败，请确认服务、登录和账号状态");
        }
        return failure(500, 500, "实时凭据服务暂不可用");
    }

    private ResponseEntity<Result<Void>> failure(int status, int code, String message) {
        return ResponseEntity.status(status).cacheControl(CacheControl.noStore()).body(Result.fail(code, message));
    }
}
