package com.shadow.backend.call.service;

import com.shadow.backend.call.dto.InitiateCallRequest;
import com.shadow.backend.call.vo.CallCursorPageVO;
import com.shadow.backend.call.vo.CallVO;

public interface CallService {
    CallVO initiate(Long userId, InitiateCallRequest request);

    CallVO accept(Long userId, String callId);

    CallVO reject(Long userId, String callId);

    CallVO cancel(Long userId, String callId);

    CallVO end(Long userId, String callId);

    CallVO activeCall(Long userId);

    CallCursorPageVO<CallVO> records(Long userId, Long beforeId, int limit);

    void onRoomFinished(String callId);
}
