package com.keysi.api_backend.domain.port.out;

import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;

public interface FileStoragePort {
    String store(MultipartFile file) throws IOException;
}