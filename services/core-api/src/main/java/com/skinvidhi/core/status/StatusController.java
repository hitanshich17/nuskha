package com.skinvidhi.core.status;

import com.skinvidhi.core.client.AiServiceClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** Quick end-to-end check that the core API is up and can reach the AI service. */
@RestController
@RequestMapping("/api/v1/status")
public class StatusController {

    private final AiServiceClient aiServiceClient;

    public StatusController(AiServiceClient aiServiceClient) {
        this.aiServiceClient = aiServiceClient;
    }

    @GetMapping
    public StatusResponse status() {
        String ai = aiServiceClient.isHealthy() ? "up" : "down";
        return new StatusResponse("core-api", "up", ai);
    }

    public record StatusResponse(String service, String status, String aiService) {
    }
}
