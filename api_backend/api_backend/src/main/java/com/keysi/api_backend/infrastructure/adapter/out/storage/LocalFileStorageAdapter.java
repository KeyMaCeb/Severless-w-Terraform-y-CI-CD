package com.keysi.api_backend.infrastructure.adapter.out.storage;

import com.keysi.api_backend.domain.port.out.FileStoragePort;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

@Component
public class LocalFileStorageAdapter implements FileStoragePort {

    private final Path root = Paths.get("uploads");

    public LocalFileStorageAdapter() throws IOException {
        Files.createDirectories(root);
    }

    @Override
    public String store(MultipartFile file) throws IOException {
        String filename = UUID.randomUUID() + "_" + file.getOriginalFilename();
        Files.copy(file.getInputStream(), root.resolve(filename));
        return "/files/" + filename;
    }
}