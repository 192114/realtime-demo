package com.shadow.backend.chat.controller;

import com.shadow.backend.chat.dto.CreateDirectConversationRequest;
import com.shadow.backend.chat.dto.ReadConversationRequest;
import com.shadow.backend.chat.dto.SendMessageRequest;
import com.shadow.backend.chat.service.ChatService;
import com.shadow.backend.chat.vo.ChatConversationVO;
import com.shadow.backend.chat.vo.ChatCursorPageVO;
import com.shadow.backend.chat.vo.ChatMessageVO;
import com.shadow.backend.chat.vo.ChatReadVO;
import com.shadow.backend.common.response.Result;
import com.shadow.backend.common.util.LoginUserUtil;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/app/chat/conversations")
public class ChatController {
    private final ChatService chatService;

    @PostMapping("/direct")
    public Result<ChatConversationVO> createDirect(@Valid @RequestBody CreateDirectConversationRequest request) {
        return Result.success(chatService.createDirect(LoginUserUtil.currentUserId(), request.getPeerUserId()));
    }

    @GetMapping
    public Result<ChatCursorPageVO<ChatConversationVO>> conversations(
            @RequestParam(required = false) Long beforeId, @RequestParam(defaultValue = "50") int limit) {
        return Result.success(chatService.conversations(LoginUserUtil.currentUserId(), beforeId, limit));
    }

    @GetMapping("/{id}/messages")
    public Result<ChatCursorPageVO<ChatMessageVO>> history(@PathVariable Long id,
            @RequestParam(required = false) Long beforeSeq, @RequestParam(defaultValue = "50") int limit) {
        return Result.success(chatService.history(LoginUserUtil.currentUserId(), id, beforeSeq, limit));
    }

    @GetMapping("/{id}/sync")
    public Result<ChatCursorPageVO<ChatMessageVO>> sync(@PathVariable Long id,
            @RequestParam(defaultValue = "0") Long afterSeq, @RequestParam(defaultValue = "100") int limit) {
        return Result.success(chatService.sync(LoginUserUtil.currentUserId(), id, afterSeq, limit));
    }

    @PostMapping("/{id}/messages")
    public Result<ChatMessageVO> send(@PathVariable Long id, @Valid @RequestBody SendMessageRequest request) {
        return Result.success(chatService.send(LoginUserUtil.currentUserId(), id, request));
    }

    @PutMapping("/{id}/read")
    public Result<ChatReadVO> read(@PathVariable Long id, @Valid @RequestBody ReadConversationRequest request) {
        return Result.success(chatService.read(LoginUserUtil.currentUserId(), id, request.getSeq()));
    }
}
