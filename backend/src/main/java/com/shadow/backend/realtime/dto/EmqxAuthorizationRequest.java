package com.shadow.backend.realtime.dto;

import lombok.Data;
import lombok.ToString;
import tools.jackson.databind.JsonNode;

@Data
@ToString(onlyExplicitlyIncluded = true)
public class EmqxAuthorizationRequest {
    private String username;
    private String clientid;
    private String action;
    private String topic;
    private JsonNode qos;
    private JsonNode retain;
}
