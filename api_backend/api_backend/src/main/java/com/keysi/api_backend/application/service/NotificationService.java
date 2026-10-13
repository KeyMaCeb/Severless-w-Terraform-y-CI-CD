package com.keysi.api_backend.application.service;

import com.keysi.api_backend.application.port.in.NotificationUseCase;
import com.keysi.api_backend.domain.port.out.NotificationPublisherPort;
import org.springframework.stereotype.Service;

@Service
public class NotificationService implements NotificationUseCase {

    private final NotificationPublisherPort publisher;

    public NotificationService(NotificationPublisherPort publisher) {
        this.publisher = publisher;
    }

    @Override
    public String enviar(String email, String subject, String message) {
        return publisher.publicar(email, subject, message);
    }
}