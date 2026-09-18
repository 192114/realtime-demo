package com.shadow.backend.call.response;

import com.shadow.backend.common.response.IResultCode;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum CallResultCode implements IResultCode {
    INVALID_ARGUMENT(400, "通话参数不合法"),
    SELF_CALL_FORBIDDEN(400, "不能与自己发起通话"),
    USER_UNAVAILABLE(403, "用户不存在、未启用或未通过审核"),
    CALL_FORBIDDEN(403, "无权访问此通话"),
    CALL_ALREADY_ACTIVE(409, "双方已存在进行中的通话"),
    CALL_STATE_CONFLICT(409, "当前通话状态不允许此操作");

    private final int code;
    private final String msg;
}
