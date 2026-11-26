package com.keysi.chat;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;


@Component
public class ChatWebSocketHandler extends TextWebSocketHandler {

    private static final DateTimeFormatter FORMATO =
            DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");

    private final Map<WebSocketSession, String> usuarios = new ConcurrentHashMap<>();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) {
        System.out.println("[" + ahora() + "] Conexión abierta: " + session.getId());
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) {
        String[] partes = message.getPayload().split("\\|", 2);
        if (partes.length < 2) {
            return;
        }
        String tipo = partes[0];
        String contenido = partes[1].trim();
        if (contenido.isEmpty()) {
            return;
        }

        if (tipo.equals("JOIN")) {
            usuarios.put(session, contenido);
            broadcast("SYS|" + ahora() + "|" + contenido + " se conectó ("
                    + usuarios.size() + " en línea)");
        } else if (tipo.equals("MSG")) {
            String nombre = usuarios.get(session);
            if (nombre != null) {
                broadcast("CHAT|" + ahora() + "|" + nombre + "|" + contenido);
            }
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        String nombre = usuarios.remove(session);
        System.out.println("[" + ahora() + "] Conexión cerrada: " + session.getId());
        if (nombre != null) {
            broadcast("SYS|" + ahora() + "|" + nombre + " se desconectó ("
                    + usuarios.size() + " en línea)");
        }
    }

    private void broadcast(String texto) {
        TextMessage mensaje = new TextMessage(texto);
        for (WebSocketSession s : usuarios.keySet()) {
            if (!s.isOpen()) {
                continue;
            }
            try {
                synchronized (s) {
                    s.sendMessage(mensaje);
                }
            } catch (IOException e) {
                System.out.println("No se pudo enviar a " + s.getId() + ": " + e.getMessage());
            }
        }
    }

    private String ahora() {
        return LocalDateTime.now().format(FORMATO);
    }
}
