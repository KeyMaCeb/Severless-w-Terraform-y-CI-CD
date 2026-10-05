package com.keysi.api_backend.infrastructure.adapter.out.storage;

import com.keysi.api_backend.domain.port.out.FileStoragePort;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

import java.io.IOException;
import java.util.UUID;

@Component
public class LocalFileStorageAdapter implements FileStoragePort {

    private final S3Client s3Client;
    private final String bucketName;

    public LocalFileStorageAdapter() {
        this.bucketName = System.getenv("FILE_STORAGE_BUCKET");

        if (bucketName == null || bucketName.isBlank()) {
            throw new IllegalStateException("FILE_STORAGE_BUCKET no está configurado");
        }

        String region = System.getenv("AWS_REGION");

        this.s3Client = S3Client.builder()
                .region(Region.of(region))
                .build();
    }

    @Override
    public String store(MultipartFile file) throws IOException {
        String filename = UUID.randomUUID() + "_" + file.getOriginalFilename();

        PutObjectRequest request = PutObjectRequest.builder()
                .bucket(bucketName)
                .key(filename)
                .contentType(file.getContentType())
                .build();

        s3Client.putObject(
                request,
                RequestBody.fromInputStream(file.getInputStream(), file.getSize())
        );

        return "s3://" + bucketName + "/" + filename;
    }
}