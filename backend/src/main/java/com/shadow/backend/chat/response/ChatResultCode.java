package com.shadow.backend.chat.response;

import com.shadow.backend.common.response.IResultCode;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum ChatResultCode implements IResultCode {
    INVALID_ARGUMENT(400, "聊天参数不合法"),
    SELF_CHAT_FORBIDDEN(400, "不能与自己创建单聊"),
    USER_UNAVAILABLE(403, "用户不存在、未启用或未通过审核"),
    CONVERSATION_FORBIDDEN(403, "无权访问此会话"),
    CLIENT_MESSAGE_CONFLICT(409, "客户端消息ID已用于不同文本"),
    SEQUENCE_EXHAUSTED(409, "会话消息序号已达上限");

    private final int code;
    private final String msg;
}
