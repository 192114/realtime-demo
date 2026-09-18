package com.shadow.backend.chat.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.ToString;

import java.time.LocalDateTime;

@Data
@TableName("chat_outbox")
public class ChatOutbox {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String eventId;
    private Long recipientId;
    private String topic;
    @ToString.Exclude
    private String payload;
    private Integer attempts;
    private String claimToken;
    private LocalDateTime leaseUntil;
    private LocalDateTime nextAttemptAt;
    private LocalDateTime deliveredAt;
    private String lastError;
    private LocalDateTime createdAt;
}
