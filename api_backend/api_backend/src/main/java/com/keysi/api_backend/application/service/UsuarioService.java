package com.keysi.api_backend.application.service;

import com.keysi.api_backend.application.port.in.UsuarioUseCase;
import com.keysi.api_backend.domain.model.Usuario;
import com.keysi.api_backend.domain.port.out.UsuarioRepositoryPort;
import org.springframework.stereotype.Service;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.List;

@Service
public class UsuarioService implements UsuarioUseCase {

    private final UsuarioRepositoryPort repository;
    private final PasswordEncoder passwordEncoder;

    public UsuarioService(
            UsuarioRepositoryPort repository,
            PasswordEncoder passwordEncoder) {

        this.repository = repository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public Usuario crear(Usuario usuario) {

        String passwordEncriptada =
                passwordEncoder.encode(usuario.getPassword());

        usuario.setPassword(passwordEncriptada);

        return repository.guardar(usuario);
    }

    @Override
    public List<Usuario> listar() {
        return repository.listar();
    }

    @Override
    public Usuario buscarPorId(Long id) {

        return repository.buscarPorId(id)
                .orElseThrow(() ->
                        new RuntimeException("Usuario no encontrado"));
    }
    @Override
    public Usuario buscarPorEmail(String email) {
        return repository.buscarPorEmail(email)
                .orElseThrow(() ->
                        new RuntimeException("Usuario no encontrado"));
    }

    @Override
    public Usuario actualizar(Long id, Usuario usuario) {

        Usuario existente = buscarPorId(id);

        existente.setNombre(usuario.getNombre());
        existente.setEmail(usuario.getEmail());

        return repository.guardar(existente);
    }

    @Override
    public void eliminar(Long id) {

        buscarPorId(id);

        repository.eliminar(id);
    }

    public Usuario actualizarFoto(Long id, String fotoUrl) {
        Usuario existente = buscarPorId(id);
        existente.setFotoUrl(fotoUrl);
        return repository.guardar(existente);
    }
}
