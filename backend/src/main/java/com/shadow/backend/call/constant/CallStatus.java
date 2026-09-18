package com.shadow.backend.call.constant;

import com.shadow.backend.call.response.CallResultCode;
import com.shadow.backend.common.exception.BusinessException;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum CallStatus {
    CALLING(0),
    IN_CALL(1),
    REJECTED(2),
    CANCELLED(3),
    TIMEOUT(4),
    ENDED(5);

    private final int value;

    public static CallStatus fromValue(Integer value) {
        if (value == null) {
            return null;
        }
        for (CallStatus status : values()) {
            if (status.value == value) {
                return status;
            }
        }
        throw new BusinessException(CallResultCode.INVALID_ARGUMENT);
    }

    public boolean isTerminal() {
        return this == REJECTED || this == CANCELLED || this == TIMEOUT || this == ENDED;
    }
}
