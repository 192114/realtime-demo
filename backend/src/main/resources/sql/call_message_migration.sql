-- 手工执行的非破坏增量迁移；先选择与应用相同的数据库，再执行本文件。
-- 第三阶段:通话终态回写聊天记录;所有 DATETIME(6) 均为 UTC。
-- ALTER 不支持 IF NOT EXISTS,重复执行会因列/约束已存在而失败,仅执行一次。

ALTER TABLE chat_message
    ADD COLUMN type VARCHAR(16) NOT NULL DEFAULT 'TEXT' COMMENT '消息类型:TEXT 文本 / CALL 通话记录' AFTER client_msg_id,
    ADD COLUMN call_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin DEFAULT NULL COMMENT '关联通话UUID,type=CALL 时必填' AFTER type;

ALTER TABLE chat_message
    ADD CONSTRAINT chk_chat_message_type CHECK (type IN ('TEXT', 'CALL')),
    ADD CONSTRAINT chk_chat_message_call CHECK (type <> 'CALL' OR call_id IS NOT NULL);
