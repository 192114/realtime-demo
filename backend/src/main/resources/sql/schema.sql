CREATE DATABASE IF NOT EXISTS realtime DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE realtime;

CREATE TABLE IF NOT EXISTS app_user (
    id          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    phone       VARCHAR(20)  NOT NULL COMMENT '手机号',
    username    VARCHAR(32)  DEFAULT NULL COMMENT '用户名',
    password    VARCHAR(255) NOT NULL COMMENT '密码（Argon2）',
    nickname    VARCHAR(64)  DEFAULT NULL COMMENT '昵称',
    avatar      VARCHAR(255) DEFAULT NULL COMMENT '头像URL',
    email       VARCHAR(128) DEFAULT NULL COMMENT '邮箱',
    status      TINYINT      NOT NULL DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    audit_status TINYINT     NOT NULL DEFAULT 1 COMMENT '审核状态：0-待审核，1-已通过，2-已拒绝',
    audit_remark VARCHAR(255) DEFAULT NULL COMMENT '审核备注/驳回原因',
    audit_time   DATETIME    DEFAULT NULL COMMENT '审核时间',
    deleted     TINYINT      NOT NULL DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除',
    create_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_phone (phone),
    UNIQUE KEY uk_username (username),
    INDEX idx_audit_status (audit_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

CREATE TABLE IF NOT EXISTS app_sms_log (
    id            BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    phone         VARCHAR(20)  NOT NULL COMMENT '手机号',
    scene         VARCHAR(32)  NOT NULL COMMENT '场景：LOGIN/REGISTER/RESET_PASSWORD',
    code          VARCHAR(6)   NOT NULL COMMENT '验证码',
    status        TINYINT      NOT NULL DEFAULT 0 COMMENT '状态：0-已发送，1-已验证，2-已过期',
    send_time     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发送时间',
    verified_time DATETIME     DEFAULT NULL COMMENT '验证时间',
    deleted       TINYINT      NOT NULL DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除',
    create_time   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (id),
    INDEX idx_phone_scene (phone, scene),
    INDEX idx_send_time (send_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='短信验证码日志表';

CREATE TABLE IF NOT EXISTS sys_user (
    id          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    username    VARCHAR(32)  NOT NULL COMMENT '用户名',
    password    VARCHAR(255) NOT NULL COMMENT '密码（Argon2）',
    nickname    VARCHAR(64)  DEFAULT NULL COMMENT '昵称',
    email       VARCHAR(128) DEFAULT NULL COMMENT '邮箱',
    status      TINYINT      NOT NULL DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    deleted     TINYINT      NOT NULL DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除',
    create_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='管理员用户表';

-- ======================== RBAC 权限系统 ========================

CREATE TABLE IF NOT EXISTS sys_menu (
    id          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    parent_id   BIGINT       NOT NULL DEFAULT 0     COMMENT '父菜单ID, 0=根节点',
    name        VARCHAR(64)  NOT NULL               COMMENT '菜单名称',
    type        TINYINT      NOT NULL               COMMENT '类型: 1=目录 2=菜单 3=按钮',
    path        VARCHAR(128) DEFAULT NULL           COMMENT '路由路径',
    icon        VARCHAR(64)  DEFAULT NULL           COMMENT '图标(lucide名称)',
    sort_order  INT          NOT NULL DEFAULT 0     COMMENT '排序',
    permission  VARCHAR(128) DEFAULT NULL           COMMENT '权限标识如 user:create',
    visible     TINYINT      NOT NULL DEFAULT 1     COMMENT '是否可见: 0=隐藏 1=显示',
    status      TINYINT      NOT NULL DEFAULT 1     COMMENT '状态: 0=禁用 1=启用',
    deleted     TINYINT      NOT NULL DEFAULT 0     COMMENT '逻辑删除',
    create_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (id),
    INDEX idx_parent_id (parent_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='菜单权限表';

CREATE TABLE IF NOT EXISTS sys_role (
    id          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    name        VARCHAR(64)  NOT NULL               COMMENT '角色名称',
    code        VARCHAR(64)  NOT NULL               COMMENT '角色编码',
    sort_order  INT          NOT NULL DEFAULT 0     COMMENT '排序',
    status      TINYINT      NOT NULL DEFAULT 1     COMMENT '状态: 0=禁用 1=启用',
    remark      VARCHAR(256) DEFAULT NULL           COMMENT '备注',
    deleted     TINYINT      NOT NULL DEFAULT 0     COMMENT '逻辑删除',
    create_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色表';

CREATE TABLE IF NOT EXISTS sys_role_menu (
    id      BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
    role_id BIGINT NOT NULL COMMENT '角色ID',
    menu_id BIGINT NOT NULL COMMENT '菜单ID',
    PRIMARY KEY (id),
    UNIQUE KEY uk_role_menu (role_id, menu_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色菜单关联表';

CREATE TABLE IF NOT EXISTS sys_user_role (
    id      BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
    user_id BIGINT NOT NULL COMMENT '管理员ID (sys_user.id)',
    role_id BIGINT NOT NULL COMMENT '角色ID',
    PRIMARY KEY (id),
    UNIQUE KEY uk_user_role (user_id, role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='管理员角色关联表';

-- 聊天表与 chat_migration.sql 保持一致；所有 DATETIME(6) 均为 UTC。
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
