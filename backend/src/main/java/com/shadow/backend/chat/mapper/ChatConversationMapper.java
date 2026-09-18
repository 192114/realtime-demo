package com.shadow.backend.chat.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.shadow.backend.chat.entity.ChatConversation;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.LocalDateTime;
import java.util.List;

@Mapper
public interface ChatConversationMapper extends BaseMapper<ChatConversation> {
    // 唯一用户对上的无副作用 upsert，使两个方向并发创建归并到同一行。
    @Insert("""
            INSERT INTO chat_conversation
                (user_low_id, user_high_id, last_seq, low_read_seq, high_read_seq, created_at, updated_at)
            VALUES (#{low}, #{high}, 0, 0, 0, #{now}, #{now})
            ON DUPLICATE KEY UPDATE id = id
            """)
    int createDirect(@Param("low") Long low, @Param("high") Long high, @Param("now") LocalDateTime now);

    @Select("SELECT * FROM chat_conversation WHERE user_low_id = #{low} AND user_high_id = #{high} FOR UPDATE")
    ChatConversation lockPair(@Param("low") Long low, @Param("high") Long high);

    @Select("SELECT * FROM chat_conversation WHERE id = #{id} FOR UPDATE")
    ChatConversation lockById(@Param("id") Long id);

    @Select("""
            <script>
            SELECT c.* FROM chat_conversation c
            JOIN app_user p ON p.id = CASE WHEN c.user_low_id = #{userId}
                THEN c.user_high_id ELSE c.user_low_id END
            WHERE (c.user_low_id = #{userId} OR c.user_high_id = #{userId})
                AND p.deleted = 0 AND p.status = 1 AND p.audit_status = #{approved}
            <if test="beforeId != null">AND c.id &lt; #{beforeId}</if>
            ORDER BY c.id DESC LIMIT #{limit}
            </script>
            """)
    List<ChatConversation> findPage(@Param("userId") Long userId, @Param("beforeId") Long beforeId,
                                    @Param("limit") int limit, @Param("approved") int approved);
}
