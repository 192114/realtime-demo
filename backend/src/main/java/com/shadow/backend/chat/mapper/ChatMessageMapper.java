package com.shadow.backend.chat.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.shadow.backend.chat.entity.ChatMessage;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface ChatMessageMapper extends BaseMapper<ChatMessage> {
    // 在会话行锁之后使用当前读，避免 REPEATABLE READ 的旧快照漏掉并发提交的幂等消息。
    @Select("""
            SELECT * FROM chat_message WHERE conversation_id = #{conversationId}
                AND sender_id = #{senderId} AND client_msg_id = #{clientMsgId} FOR UPDATE
            """)
    ChatMessage findIdempotent(@Param("conversationId") Long conversationId, @Param("senderId") Long senderId,
                               @Param("clientMsgId") String clientMsgId);

    @Select("""
            <script>
            SELECT * FROM chat_message WHERE conversation_id = #{conversationId}
            <if test="beforeSeq != null">AND seq &lt; #{beforeSeq}</if>
            ORDER BY seq DESC LIMIT #{limit}
            </script>
            """)
    List<ChatMessage> history(@Param("conversationId") Long conversationId, @Param("beforeSeq") Long beforeSeq,
                              @Param("limit") int limit);

    @Select("""
            SELECT * FROM chat_message WHERE conversation_id = #{conversationId} AND seq > #{afterSeq}
            ORDER BY seq ASC LIMIT #{limit}
            """)
    List<ChatMessage> sync(@Param("conversationId") Long conversationId, @Param("afterSeq") Long afterSeq,
                           @Param("limit") int limit);

    @Select("""
            SELECT COUNT(*) FROM chat_message WHERE conversation_id = #{conversationId}
                AND sender_id = #{peerId} AND seq > #{readSeq}
            """)
    Long countUnread(@Param("conversationId") Long conversationId, @Param("peerId") Long peerId,
                     @Param("readSeq") Long readSeq);
}
