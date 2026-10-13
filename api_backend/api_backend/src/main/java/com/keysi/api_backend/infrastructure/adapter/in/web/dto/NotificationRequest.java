package com.keysi.api_backend.infrastructure.adapter.in.web.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record NotificationRequest(
        @NotBlank @Email String email,
        @NotBlank @Size(max = 150) String subject,
        @NotBlank @Size(max = 5000) String message) {}