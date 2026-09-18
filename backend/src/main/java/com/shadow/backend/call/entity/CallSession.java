package com.shadow.backend.call.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("call_session")
public class CallSession {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String callId;
    private Long conversationId;
    private Long callerId;
    private Long calleeId;
    private Integer status;
    private String mediaType;
    private String endReason;
    private LocalDateTime createdAt;
    private LocalDateTime acceptedAt;
    private LocalDateTime endedAt;
}
