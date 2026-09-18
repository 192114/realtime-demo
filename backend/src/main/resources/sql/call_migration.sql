-- 手工执行的非破坏增量迁移；先选择与应用相同的数据库，再执行本文件。
-- 第二阶段音视频通话状态记录；所有 DATETIME(6) 均为 UTC。

CREATE TABLE IF NOT EXISTS call_session (
    id              BIGINT NOT NULL AUTO_INCREMENT COMMENT '通话记录ID，游标分页使用',
    call_id         VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '通话UUID，LiveKit房间名为 call_{call_id}',
    conversation_id BIGINT NOT NULL COMMENT '关联单聊会话ID',
    caller_id       BIGINT NOT NULL COMMENT '主叫用户ID',
    callee_id       BIGINT NOT NULL COMMENT '被叫用户ID',
    status          TINYINT NOT NULL COMMENT '0呼叫中 1通话中 2已拒绝 3已取消 4已超时 5已结束',
    media_type      VARCHAR(16) NOT NULL COMMENT 'AUDIO 或 VIDEO',
    end_reason      VARCHAR(32) DEFAULT NULL COMMENT '结束原因：rejected/cancelled/timeout/hangup/room_finished',
    created_at      DATETIME(6) NOT NULL COMMENT 'UTC发起时间',
    accepted_at     DATETIME(6) DEFAULT NULL COMMENT 'UTC接听时间',
    ended_at        DATETIME(6) DEFAULT NULL COMMENT 'UTC结束时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_call_call_id (call_id),
    KEY idx_call_caller (caller_id, status, id),
    KEY idx_call_callee (callee_id, status, id),
    KEY idx_call_timeout (status, created_at),
    CONSTRAINT fk_call_conversation FOREIGN KEY (conversation_id) REFERENCES chat_conversation (id),
    CONSTRAINT chk_call_pair CHECK (caller_id <> callee_id),
    CONSTRAINT chk_call_status CHECK (status BETWEEN 0 AND 5),
    CONSTRAINT chk_call_media CHECK (media_type IN ('AUDIO', 'VIDEO')),
    CONSTRAINT chk_call_time CHECK (accepted_at IS NULL OR accepted_at >= created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='音视频通话状态记录';
