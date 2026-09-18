package com.shadow.backend.chat.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("chat_message")
public class ChatMessage {
    public static final String TYPE_TEXT = "TEXT";
    public static final String TYPE_CALL = "CALL";

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long conversationId;
    private Long senderId;
    private String clientMsgId;
    private String type;
    private String callId;
    private Long seq;
    private String text;
    private LocalDateTime createdAt;
}
