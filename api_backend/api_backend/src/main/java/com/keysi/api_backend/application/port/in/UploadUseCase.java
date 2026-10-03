package com.keysi.api_backend.application.port.in;

import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;

public interface UploadUseCase {
    String subirArchivo(MultipartFile file) throws IOException;
}