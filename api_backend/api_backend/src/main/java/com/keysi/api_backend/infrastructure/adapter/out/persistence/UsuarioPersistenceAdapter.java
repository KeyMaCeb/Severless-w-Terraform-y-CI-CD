package com.keysi.api_backend.infrastructure.adapter.out.persistence;

import com.keysi.api_backend.domain.model.Usuario;
import com.keysi.api_backend.domain.port.out.UsuarioRepositoryPort;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Optional;

@Component
public class UsuarioPersistenceAdapter
        implements UsuarioRepositoryPort {

    private final UsuarioJpaRepository repository;

    public UsuarioPersistenceAdapter(UsuarioJpaRepository repository) {
        this.repository = repository;
    }

    @Override
    public Usuario guardar(Usuario usuario) {

        UsuarioEntity entity = new UsuarioEntity();

        entity.setId(usuario.getId());
        entity.setNombre(usuario.getNombre());
        entity.setEmail(usuario.getEmail());
        entity.setPassword(usuario.getPassword());
        entity.setFotoUrl(usuario.getFotoUrl());

        UsuarioEntity guardado = repository.save(entity);

        return convertirADominio(guardado);
    }

    @Override
    public List<Usuario> listar() {

        return repository.findAll()
                .stream()
                .map(this::convertirADominio)
                .toList();
    }

    @Override
    public Optional<Usuario> buscarPorId(Long id) {

        return repository.findById(id)
                .map(this::convertirADominio);
    }

    @Override
    public Optional<Usuario> buscarPorEmail(String email) {

        return repository.findByEmail(email)
                .map(this::convertirADominio);
    }

    @Override
    public void eliminar(Long id) {

        repository.deleteById(id);
    }

    private Usuario convertirADominio(UsuarioEntity entity) {

        return new Usuario(
                entity.getId(),
                entity.getNombre(),
                entity.getEmail(),
                entity.getPassword(),
                entity.getFotoUrl()
        );
    }
}
