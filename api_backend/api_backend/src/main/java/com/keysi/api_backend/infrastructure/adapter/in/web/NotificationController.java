package com.keysi.api_backend.infrastructure.adapter.in.web;

import com.keysi.api_backend.application.port.in.NotificationUseCase;
import com.keysi.api_backend.infrastructure.adapter.in.web.dto.NotificationRequest;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/notifications")
public class NotificationController {

    private final NotificationUseCase useCase;

    public NotificationController(NotificationUseCase useCase) {
        this.useCase = useCase;
    }

    @PostMapping("/send")
    public ResponseEntity<Map<String, String>> send(@Valid @RequestBody NotificationRequest req) {
        String id = useCase.enviar(req.email(), req.subject(), req.message());
        return ResponseEntity.ok(Map.of("status", "ok", "messageId", id));
    }
}