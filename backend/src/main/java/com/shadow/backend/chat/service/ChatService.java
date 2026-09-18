package com.shadow.backend.chat.service;

import com.shadow.backend.chat.dto.SendMessageRequest;
import com.shadow.backend.chat.vo.ChatConversationVO;
import com.shadow.backend.chat.vo.ChatCursorPageVO;
import com.shadow.backend.chat.vo.ChatMessageVO;
import com.shadow.backend.chat.vo.ChatReadVO;

public interface ChatService {
    ChatConversationVO createDirect(Long userId, Long peerUserId);

    ChatCursorPageVO<ChatConversationVO> conversations(Long userId, Long beforeId, int limit);

    ChatCursorPageVO<ChatMessageVO> history(Long userId, Long conversationId, Long beforeSeq, int limit);

    ChatCursorPageVO<ChatMessageVO> sync(Long userId, Long conversationId, Long afterSeq, int limit);

    ChatMessageVO send(Long userId, Long conversationId, SendMessageRequest request);

    ChatReadVO read(Long userId, Long conversationId, Long seq);
}
