-- 手工执行的非破坏增量迁移；先选择与应用相同的数据库，再执行本文件。
-- 与 schema.sql 的聊天表保持一致；所有 DATETIME(6) 均为 UTC。

CREATE TABLE IF NOT EXISTS chat_conversation (
    id              BIGINT NOT NULL AUTO_INCREMENT COMMENT '会话ID',
    user_low_id     BIGINT NOT NULL COMMENT '较小用户ID',
    user_high_id    BIGINT NOT NULL COMMENT '较大用户ID',
    last_seq        BIGINT NOT NULL DEFAULT 0 COMMENT '最后提交的消息序号',
    low_read_seq    BIGINT NOT NULL DEFAULT 0 COMMENT '较小用户已读序号',
    high_read_seq   BIGINT NOT NULL DEFAULT 0 COMMENT '较大用户已读序号',
    last_text       VARCHAR(4000) DEFAULT NULL COMMENT '最后一条消息文本',
    created_at      DATETIME(6) NOT NULL COMMENT 'UTC创建时间',
    updated_at      DATETIME(6) NOT NULL COMMENT 'UTC更新时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_chat_pair (user_low_id, user_high_id),
    KEY idx_chat_low (user_low_id, id),
    KEY idx_chat_high (user_high_id, id),
    CONSTRAINT chk_chat_pair CHECK (user_low_id < user_high_id),
    CONSTRAINT chk_chat_seq CHECK (last_seq >= 0 AND low_read_seq >= 0 AND high_read_seq >= 0
        AND low_read_seq <= last_seq AND high_read_seq <= last_seq)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='可靠文本单聊会话';

CREATE TABLE IF NOT EXISTS chat_message (
    id              BIGINT NOT NULL AUTO_INCREMENT COMMENT '消息ID',
    conversation_id BIGINT NOT NULL COMMENT '会话ID',
    sender_id       BIGINT NOT NULL COMMENT '发送用户ID',
    client_msg_id   VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '大小写敏感UUID幂等键',
    type            VARCHAR(16) NOT NULL DEFAULT 'TEXT' COMMENT '消息类型:TEXT 文本 / CALL 通话记录',
    call_id         VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin DEFAULT NULL COMMENT '关联通话UUID,type=CALL 时必填',
    seq             BIGINT NOT NULL COMMENT '会话内连续递增序号',
    text            VARCHAR(4000) NOT NULL COMMENT '文本消息',
    created_at      DATETIME(6) NOT NULL COMMENT 'UTC创建时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_chat_message_seq (conversation_id, seq),
    UNIQUE KEY uk_chat_message_client (conversation_id, sender_id, client_msg_id),
    KEY idx_chat_unread (conversation_id, sender_id, seq),
    CONSTRAINT fk_chat_message_conversation FOREIGN KEY (conversation_id) REFERENCES chat_conversation (id),
    CONSTRAINT chk_chat_message_seq CHECK (seq > 0),
    CONSTRAINT chk_chat_message_type CHECK (type IN ('TEXT', 'CALL')),
    CONSTRAINT chk_chat_message_call CHECK (type <> 'CALL' OR call_id IS NOT NULL)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='可靠单聊消息';

CREATE TABLE IF NOT EXISTS chat_outbox (
    id              BIGINT NOT NULL AUTO_INCREMENT COMMENT '投递任务ID',
    event_id        VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '逻辑事件UUID',
    recipient_id    BIGINT NOT NULL COMMENT '接收用户ID，包含发送者自身',
    topic           VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '用户事件主题',
    payload         MEDIUMTEXT NOT NULL COMMENT '完整事件JSON，不得写入日志',
    attempts        INT NOT NULL DEFAULT 0 COMMENT '抢占尝试次数',
    claim_token     VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin DEFAULT NULL COMMENT '每次抢占的唯一随机令牌',
    lease_until     DATETIME(6) DEFAULT NULL COMMENT 'UTC租约截止时间',
    next_attempt_at DATETIME(6) NOT NULL COMMENT 'UTC下次尝试时间',
    delivered_at    DATETIME(6) DEFAULT NULL COMMENT 'Broker确认时间，不代表设备送达或已读',
    last_error      VARCHAR(128) DEFAULT NULL COMMENT '最近失败的异常类型，不含消息或凭证',
    created_at      DATETIME(6) NOT NULL COMMENT 'UTC创建时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_chat_event_recipient (event_id, recipient_id),
    UNIQUE KEY uk_chat_claim_token (claim_token),
    KEY idx_chat_outbox_due (delivered_at, next_attempt_at, id),
    KEY idx_chat_outbox_lease (delivered_at, lease_until),
    CONSTRAINT chk_chat_outbox_attempts CHECK (attempts >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='至少一次事件投递Outbox，失败无限重试';
