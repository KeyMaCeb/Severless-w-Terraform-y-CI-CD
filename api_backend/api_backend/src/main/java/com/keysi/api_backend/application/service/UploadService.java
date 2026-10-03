package com.keysi.api_backend.application.service;

import com.keysi.api_backend.application.port.in.UploadUseCase;
import com.keysi.api_backend.domain.port.out.FileStoragePort;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;

@Service
public class UploadService implements UploadUseCase {

    private final FileStoragePort fileStoragePort;

    public UploadService(FileStoragePort fileStoragePort) {
        this.fileStoragePort = fileStoragePort;
    }

    @Override
    public String subirArchivo(MultipartFile file) throws IOException {
        return fileStoragePort.store(file);
    }
}