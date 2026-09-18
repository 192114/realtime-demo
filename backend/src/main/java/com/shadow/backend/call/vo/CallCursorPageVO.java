package com.shadow.backend.call.vo;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.List;

@Data
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.ALWAYS)
public class CallCursorPageVO<T> {
    private List<T> items;
    private boolean hasMore;
    // 有数据时返回本页最后一项的游标，空页为 null。
    private Long nextCursor;
}
