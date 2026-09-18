package com.shadow.backend.realtime.dto;

import lombok.Data;
import lombok.ToString;

@Data
@ToString(onlyExplicitlyIncluded = true)
public class EmqxAuthenticationRequest {
    private String username;
    private String password;
    private String clientid;
}
