package com.shadow.backend.realtime.security;

import java.util.List;
import java.util.regex.Pattern;

public final class RealtimeTopics {
    private static final Pattern PERSONAL_TOPIC = Pattern.compile("chat/user/([1-9][0-9]{0,18})/(events|calls)");

    private RealtimeTopics() {
    }

    public static List<String> forUser(long userId) {
        return List.of("chat/user/" + userId + "/events", "chat/user/" + userId + "/calls");
    }

    public static boolean isPersonalTopic(String topic) {
        if (topic == null) {
            return false;
        }
        var matcher = PERSONAL_TOPIC.matcher(topic);
        if (!matcher.matches()) {
            return false;
        }
        try {
            return Long.parseLong(matcher.group(1)) > 0;
        } catch (NumberFormatException ex) {
            return false;
        }
    }
}
