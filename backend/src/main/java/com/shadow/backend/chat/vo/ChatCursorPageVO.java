package com.shadow.backend.chat.vo;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.List;

@Data
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.ALWAYS)
public class ChatCursorPageVO<T> {
    private List<T> items;
    private boolean hasMore;
    // 有数据时返回本页最后一项的游标，空页为 null；同步端可保留上次游标。
    private Long nextCursor;
}
