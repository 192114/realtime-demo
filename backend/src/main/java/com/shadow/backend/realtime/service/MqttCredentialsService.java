package com.shadow.backend.realtime.service;

import com.shadow.backend.realtime.dto.MqttCredentialsRequest;
import com.shadow.backend.realtime.vo.MqttCredentialsVO;

public interface MqttCredentialsService {
    MqttCredentialsVO issue(MqttCredentialsRequest request);
}
