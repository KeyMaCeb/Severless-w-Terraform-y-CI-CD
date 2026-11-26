# Chat en tiempo real con WebSockets (Spring Boot)

Servidor Spring Boot con un endpoint WebSocket (`/chat`) y un cliente web (HTML + JavaScript) servido por el mismo servidor.

## Estructura

```
websocket-chat/
├── pom.xml
└── src/main/
    ├── java/com/keysi/chat/
    │   ├── ChatApplication.java        # arranque de Spring Boot
    │   ├── WebSocketConfig.java        # registra /chat
    │   └── ChatWebSocketHandler.java   # lógica del servidor (conexión, broadcast)
    └── resources/static/index.html     # cliente web
```

## Cómo correrlo

Requisitos: JDK 17 y Maven (o abrir la carpeta en IntelliJ).

```powershell
cd websocket-chat
mvn spring-boot:run
```

Abre **http://localhost:8080** en dos pestañas (o dos navegadores), escribe un nombre distinto en cada una, pulsa **Conectar** y chatea.

## Protocolo (texto plano, campos separados por `|`)

| Dirección | Mensaje | Significado |
|---|---|---|
| cliente → servidor | `JOIN\|nombre` | el usuario entra al chat |
| cliente → servidor | `MSG\|texto` | mensaje del usuario |
| servidor → clientes | `SYS\|fecha hora\|texto` | aviso de conexión o desconexión |
| servidor → clientes | `CHAT\|fecha hora\|nombre\|texto` | mensaje con fecha y hora |

## Qué cumple de la actividad

- Varios clientes simultáneos: el servidor guarda cada sesión abierta en un `ConcurrentHashMap`.
- Aviso de conexión y desconexión: `JOIN` y `afterConnectionClosed` generan un mensaje `SYS` para todos.
- Mensajes en tiempo real sin recargar y sin polling: el servidor empuja cada mensaje con `broadcast()` por la conexión que ya está abierta.
- Fecha y hora: el servidor la añade a cada mensaje.
- Interfaz: campo de nombre, caja de texto, botón Enviar y área de mensajes.
