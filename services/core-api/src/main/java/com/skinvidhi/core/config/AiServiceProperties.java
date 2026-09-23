package com.skinvidhi.core.config;

import java.time.Duration;
import org.springframework.boot.context.properties.ConfigurationProperties;

/** Connection settings for the Python AI service, bound from skinvidhi.ai-service.* */
@ConfigurationProperties(prefix = "skinvidhi.ai-service")
public record AiServiceProperties(String baseUrl, Duration connectTimeout, Duration readTimeout) {
}
