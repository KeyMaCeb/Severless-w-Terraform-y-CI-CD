package com.keysi.api_backend.application.port.in;

public interface NotificationUseCase {
    String enviar(String email, String subject, String message);
}