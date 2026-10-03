package com.keysi.api_backend.domain.port.out;

import com.keysi.api_backend.domain.model.Usuario;

import java.util.List;
import java.util.Optional;

public interface UsuarioRepositoryPort {

    Usuario guardar(Usuario usuario);

    List<Usuario> listar();

    Optional<Usuario> buscarPorId(Long id);

    Optional<Usuario> buscarPorEmail(String email);

    void eliminar(Long id);
}