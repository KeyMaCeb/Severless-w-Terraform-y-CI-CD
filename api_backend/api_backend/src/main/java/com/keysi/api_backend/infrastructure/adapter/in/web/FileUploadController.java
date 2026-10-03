package com.keysi.api_backend.infrastructure.adapter.in.web;

import com.keysi.api_backend.application.port.in.UploadUseCase;
import com.keysi.api_backend.application.port.in.UsuarioUseCase;
import com.keysi.api_backend.domain.model.Usuario;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import java.util.Map;

@RestController
@RequestMapping("/upload")
public class FileUploadController {

    private final UploadUseCase uploadUseCase;
    private final UsuarioUseCase usuarioUseCase;

    public FileUploadController(UploadUseCase uploadUseCase, UsuarioUseCase usuarioUseCase) {
        this.uploadUseCase = uploadUseCase;
        this.usuarioUseCase = usuarioUseCase;
    }

    @PostMapping
    public ResponseEntity<Map<String, String>> upload(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "usuarioId", required = false) Long usuarioId
    ) throws IOException {

        String url = uploadUseCase.subirArchivo(file);

        if (usuarioId != null) {
            Usuario usuario = usuarioUseCase.buscarPorId(usuarioId);
            usuario.setFotoUrl(url);
            usuarioUseCase.actualizar(usuarioId, usuario);
        }

        return ResponseEntity.ok(Map.of("url", url));
    }
}