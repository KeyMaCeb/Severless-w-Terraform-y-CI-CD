package com.keysi.api_backend.application.port.in;

import com.keysi.api_backend.domain.model.Usuario;

import java.util.List;

public interface UsuarioUseCase {

    Usuario crear(Usuario usuario);

    List<Usuario> listar();

    Usuario buscarPorId(Long id);

    Usuario buscarPorEmail(String email);

    Usuario actualizar(Long id, Usuario usuario);

    void eliminar(Long id);

    Usuario actualizarFoto(Long id, String fotoUrl);
}