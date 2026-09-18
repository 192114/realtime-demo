package com.shadow.backend.chat.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("chat_conversation")
public class ChatConversation {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userLowId;
    private Long userHighId;
    private Long lastSeq;
    private Long lowReadSeq;
    private Long highReadSeq;
    private String lastText;
    // 聊天模块的数据库时间一律按 UTC 存取，不使用全局本地时间自动填充。
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
