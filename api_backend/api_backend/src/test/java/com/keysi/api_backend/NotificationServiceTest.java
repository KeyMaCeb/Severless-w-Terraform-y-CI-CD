package com.keysi.api_backend;

import com.keysi.api_backend.application.service.NotificationService;
import com.keysi.api_backend.domain.port.out.NotificationPublisherPort;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class NotificationServiceTest {

    @Test
    void enviarPublicaElMensajeYDevuelveElId() {
        NotificationPublisherPort fake = (email, subject, message) -> {
            assertEquals("usuario@correo.com", email);
            assertEquals("Prueba SNS", subject);
            assertEquals("Hola", message);
            return "msg-123";
        };

        NotificationService service = new NotificationService(fake);

        String id = service.enviar("usuario@correo.com", "Prueba SNS", "Hola");

        assertEquals("msg-123", id);
    }
}