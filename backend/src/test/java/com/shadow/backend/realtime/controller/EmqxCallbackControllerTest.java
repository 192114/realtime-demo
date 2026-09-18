package com.shadow.backend.realtime.controller;

import com.shadow.backend.common.config.JacksonConfig;
import com.shadow.backend.common.exception.GlobalExceptionHandler;
import com.shadow.backend.realtime.config.RealtimeMqttProperties;
import com.shadow.backend.realtime.response.RealtimeExceptionHandler;
import com.shadow.backend.realtime.security.EmqxCallbackFilter;
import com.shadow.backend.realtime.service.EmqxAccessService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.http.converter.StringHttpMessageConverter;
import org.springframework.http.converter.json.JacksonJsonHttpMessageConverter;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import tools.jackson.databind.json.JsonMapper;

import java.util.OptionalLong;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class EmqxCallbackControllerTest {
    private static final String SECRET = "unit-test-callback-secret-not-deployed";
    private static final String PATH = "/internal/realtime/emqx/";
    private final EmqxAccessService service = mock(EmqxAccessService.class);
    private final RealtimeMqttProperties properties = new RealtimeMqttProperties();
    private JsonMapper mapper;
    private MockMvc mvc;

    @BeforeEach
    void setup() {
        properties.setEnabled(true);
        properties.setInternalCallbackSecret(SECRET);
        var builder = JsonMapper.builder();
        new JacksonConfig().jsonMapperBuilderCustomizer().customize(builder);
        mapper = builder.build();
        mvc = MockMvcBuilders.standaloneSetup(new EmqxCallbackController(service))
                .setControllerAdvice(new RealtimeExceptionHandler(), new GlobalExceptionHandler())
                .setMessageConverters(new StringHttpMessageConverter(), new JacksonJsonHttpMessageConverter(mapper))
                .addFilters(new EmqxCallbackFilter(properties)).build();
    }

    @Test
    void nativeProtocolKeepsEpochNumericBooleanFalseAndNoResultWrapperEvenBeyond2038() throws Exception {
        assertThat(mapper.writeValueAsString(2208988800L)).isEqualTo("\"2208988800\"");
        when(service.authenticate(eq(SECRET), any())).thenReturn(OptionalLong.of(2208988800L));
        var response = mvc.perform(post(PATH + "authenticate").header("X-Realtime-Secret", SECRET)
                        .contentType(MediaType.APPLICATION_JSON).content("{\"username\":\"user\",\"password\":\"private-value\",\"clientid\":\"client\"}"))
                .andExpect(status().isOk()).andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
                .andExpect(header().string("Cache-Control", "no-store")).andReturn().getResponse();
        var json = mapper.readTree(response.getContentAsString());
        assertThat(json.get("expire_at").isIntegralNumber()).isTrue();
        assertThat(json.get("expire_at").asLong()).isEqualTo(2208988800L);
        assertThat(json.get("is_superuser").isBoolean()).isTrue();
        assertThat(json.get("is_superuser").asBoolean()).isFalse();
        assertThat(json.has("code")).isFalse();
        assertThat(json.has("acl")).isFalse();
        assertThat(response.getContentAsString()).doesNotContain("private-value", SECRET);
    }

    @Test
    void missingWrongDuplicateOrUnconfiguredSecretAlwaysHttp200DenyBeforeService() throws Exception {
        for (String endpoint : new String[]{"authenticate", "authorize"}) {
            mvc.perform(post(PATH + endpoint).contentType(MediaType.APPLICATION_JSON).content("{}"))
                    .andExpect(status().isOk()).andExpect(jsonPath("$.result").value("deny"));
            mvc.perform(post(PATH + endpoint).header("X-Realtime-Secret", "wrong").contentType(MediaType.APPLICATION_JSON).content("{}"))
                    .andExpect(status().isOk()).andExpect(jsonPath("$.result").value("deny"));
            mvc.perform(post(PATH + endpoint).header("X-Realtime-Secret", SECRET, SECRET).contentType(MediaType.APPLICATION_JSON).content("{}"))
                    .andExpect(status().isOk()).andExpect(jsonPath("$.result").value("deny"));
        }
        properties.setInternalCallbackSecret("");
        mvc.perform(post(PATH + "authenticate").header("X-Realtime-Secret", "").contentType(MediaType.APPLICATION_JSON).content("{}"))
                .andExpect(status().isOk()).andExpect(jsonPath("$.is_superuser").value(false));
        verifyNoInteractions(service);
    }

    @Test
    void malformedJsonWrongMethodMediaTypeAndExceptionsAreNativeDenyWithoutLeaks() throws Exception {
        for (String endpoint : new String[]{"authenticate", "authorize"}) {
            for (String body : new String[]{"{\"password\":\"sensitive-body\",", "[]", "{\"username\":{\"secret\":\"sensitive-body\"}}"}) {
                var response = mvc.perform(post(PATH + endpoint).header("X-Realtime-Secret", SECRET)
                                .contentType(MediaType.APPLICATION_JSON).content(body))
                        .andExpect(status().isOk()).andExpect(jsonPath("$.result").value("deny"))
                        .andReturn().getResponse();
                assertThat(response.getContentAsString()).doesNotContain("sensitive-body", "code");
            }
            mvc.perform(get(PATH + endpoint).header("X-Realtime-Secret", SECRET))
                    .andExpect(status().isOk()).andExpect(jsonPath("$.result").value("deny"));
            mvc.perform(post(PATH + endpoint).header("X-Realtime-Secret", SECRET).contentType(MediaType.TEXT_PLAIN).content("secret"))
                    .andExpect(status().isOk()).andExpect(jsonPath("$.result").value("deny"));
        }
        when(service.authenticate(any(), any())).thenThrow(new IllegalStateException("secret-token-body"));
        mvc.perform(post(PATH + "authenticate").header("X-Realtime-Secret", SECRET).contentType(MediaType.APPLICATION_JSON).content("{}"))
                .andExpect(status().isOk()).andExpect(content().json("{\"result\":\"deny\",\"is_superuser\":false}"));
        when(service.authorize(any(), any())).thenThrow(new IllegalStateException("secret-token-body"));
        mvc.perform(post(PATH + "authorize").header("X-Realtime-Secret", SECRET).contentType(MediaType.APPLICATION_JSON).content("{}"))
                .andExpect(status().isOk()).andExpect(content().json("{\"result\":\"deny\"}"));
    }
}
