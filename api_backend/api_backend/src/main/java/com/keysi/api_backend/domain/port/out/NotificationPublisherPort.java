package com.keysi.api_backend.domain.port.out;

public interface NotificationPublisherPort {
    String publicar(String email, String subject, String message);
}