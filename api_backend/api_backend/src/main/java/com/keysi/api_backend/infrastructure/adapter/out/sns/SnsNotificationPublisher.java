package com.keysi.api_backend.infrastructure.adapter.out.sns;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.keysi.api_backend.domain.port.out.NotificationPublisherPort;
import org.springframework.stereotype.Component;
import software.amazon.awssdk.services.sns.SnsClient;
import software.amazon.awssdk.services.sns.model.PublishRequest;

import java.util.Map;

@Component
public class SnsNotificationPublisher implements NotificationPublisherPort {

    private final SnsClient sns = SnsClient.create();
    private final ObjectMapper mapper = new ObjectMapper();
    private final String topicArn = System.getenv("SNS_TOPIC_ARN");

    @Override
    public String publicar(String email, String subject, String message) {
        try {
            String json = mapper.writeValueAsString(
                    Map.of("email", email, "subject", subject, "message", message));
            return sns.publish(PublishRequest.builder()
                    .topicArn(topicArn)
                    .message(json)
                    .build()).messageId();
        } catch (Exception e) {
            throw new RuntimeException("No se pudo publicar en SNS", e);
        }
    }
}