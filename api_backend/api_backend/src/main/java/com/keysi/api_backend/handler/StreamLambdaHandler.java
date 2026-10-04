
package com.keysi.api_backend.handler;

import com.amazonaws.serverless.exceptions.ContainerInitializationException;
import com.amazonaws.serverless.proxy.model.AwsProxyRequest;
import com.amazonaws.serverless.proxy.model.AwsProxyResponse;
import com.amazonaws.serverless.proxy.spring.SpringBootLambdaContainerHandler;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestStreamHandler;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public class StreamLambdaHandler implements RequestStreamHandler {

    private static SpringBootLambdaContainerHandler<AwsProxyRequest, AwsProxyResponse> handler;

    static {
        try {
            handler = SpringBootLambdaContainerHandler.getAwsProxyHandler(
                    com.keysi.api_backend.ApiBackendApplication.class
            );
        } catch (ContainerInitializationException e) {
            throw new RuntimeException("Error inicializando Spring Boot para Lambda", e);
        }
    }

    @Override
    public void handleRequest(
            InputStream input,
            OutputStream output,
            Context context
    ) throws IOException {
        handler.proxyStream(input, output, context);
    }
}