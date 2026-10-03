package com.keysi.api_backend.infrastructure.adapter.in.web;

import com.keysi.api_backend.application.port.in.UsuarioUseCase;
import com.keysi.api_backend.domain.model.Usuario;
import com.keysi.api_backend.config.JwtService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final UsuarioUseCase usuarioUseCase;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public AuthController(
            UsuarioUseCase usuarioUseCase,
            PasswordEncoder passwordEncoder,
            JwtService jwtService) {

        this.usuarioUseCase = usuarioUseCase;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    @PostMapping("/register")
    public ResponseEntity<Usuario> register(
            @RequestBody Usuario usuario) {

        return ResponseEntity.ok(
                usuarioUseCase.crear(usuario)
        );
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(
            @RequestBody Usuario usuario) {

        Usuario usuarioEncontrado =
                usuarioUseCase.buscarPorEmail(usuario.getEmail());

        if (!passwordEncoder.matches(
                usuario.getPassword(),
                usuarioEncontrado.getPassword())) {

            return ResponseEntity.status(401)
                    .body("Credenciales incorrectas");
        }

        String token =
                jwtService.generarToken(usuarioEncontrado.getEmail());

        return ResponseEntity.ok(token);
    }
}