package com.keysi.api_backend.infrastructure.adapter.in.web;

import com.keysi.api_backend.application.port.in.UsuarioUseCase;
import com.keysi.api_backend.domain.model.Usuario;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/usuarios")
public class UsuarioController {

    private final UsuarioUseCase usuarioUseCase;

    public UsuarioController(UsuarioUseCase usuarioUseCase) {
        this.usuarioUseCase = usuarioUseCase;
    }

    @GetMapping
    public ResponseEntity<List<Usuario>> listar() {
        return ResponseEntity.ok(usuarioUseCase.listar());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Usuario> buscar(@PathVariable Long id) {
        return ResponseEntity.ok(
                usuarioUseCase.buscarPorId(id)
        );
    }

    @PostMapping
    public ResponseEntity<Usuario> crear(
            @RequestBody Usuario usuario) {

        return ResponseEntity.ok(
                usuarioUseCase.crear(usuario)
        );
    }

    @PutMapping("/{id}")
    public ResponseEntity<Usuario> actualizar(
            @PathVariable Long id,
            @RequestBody Usuario usuario) {

        return ResponseEntity.ok(
                usuarioUseCase.actualizar(id, usuario)
        );
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(
            @PathVariable Long id) {

        usuarioUseCase.eliminar(id);

        return ResponseEntity.noContent().build();
    }
}