package com.keysi.api_backend.handler;

import com.amazonaws.serverless.exceptions.ContainerInitializationException;
import com.amazonaws.serverless.proxy.model.HttpApiV2ProxyRequest;
import com.amazonaws.serverless.proxy.model.AwsProxyResponse;
import com.amazonaws.serverless.proxy.spring.SpringBootLambdaContainerHandler;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestStreamHandler;
import com.keysi.api_backend.ApiBackendApplication;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public class StreamLambdaHandler implements RequestStreamHandler {

    private static final SpringBootLambdaContainerHandler<HttpApiV2ProxyRequest, AwsProxyResponse> handler;

    static {
        try {
            handler = SpringBootLambdaContainerHandler.getHttpApiV2ProxyHandler(
                    ApiBackendApplication.class
            );
        } catch (ContainerInitializationException e) {
            throw new RuntimeException(
                    "Could not initialize Spring Boot application",
                    e
            );
        }
    }

    @Override
    public void handleRequest(
            InputStream inputStream,
            OutputStream outputStream,
            Context context
    ) throws IOException {

        handler.proxyStream(inputStream, outputStream, context);
    }
}