package com.shadow.backend.chat.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;
import lombok.ToString;

@Data
public class SendMessageRequest {
    public static final String CLIENT_MSG_ID_PATTERN = "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}";
    public static final int MAX_TEXT_LENGTH = 4000;

    @NotBlank(message = "客户端消息ID不能为空")
    @Pattern(regexp = CLIENT_MSG_ID_PATTERN, message = "客户端消息ID必须为UUID格式")
    private String clientMsgId;
    @NotBlank(message = "消息文本不能为空")
    @Size(max = MAX_TEXT_LENGTH, message = "消息文本不能超过4000个字符")
    @ToString.Exclude
    private String text;
}
