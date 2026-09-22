package com.nuskha.core.config;

import java.time.Duration;
import org.springframework.boot.context.properties.ConfigurationProperties;

/** Connection settings for the Python AI service, bound from nuskha.ai-service.* */
@ConfigurationProperties(prefix = "nuskha.ai-service")
public record AiServiceProperties(String baseUrl, Duration connectTimeout, Duration readTimeout) {
}
