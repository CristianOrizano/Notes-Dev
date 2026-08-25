# 🚀 Arquitectura Reactiva de Microservicios
### Stack Tecnológico & Guía de Implementación

---

## 1. 🧠 Core del Microservicio — Desarrollo 100% Reactivo

Son los lenguajes y frameworks con los que se programa la lógica de negocio de una API de alta concurrencia.

| Tecnología | Descripción |
|---|---|
| **Java 17 / Java 21** | Lenguaje backend base. Java 21 es ideal para aprovechar las últimas optimizaciones de rendimiento. |
| **Spring WebFlux** | Framework reactivo esencial. Reemplaza el modelo tradicional de hilos (Tomcat) por un motor asíncrono basado en **Netty**, capaz de manejar miles de conexiones simultáneas. |
| **Spring Data Reactive MongoDB** | Driver y repositorio reactivo (`ReactiveMongoRepository`) para interactuar con la base de datos de forma no bloqueante. |
| **Lombok** | Librería para mantener el código limpio y libre de boilerplate (getters, setters, builders y constructores automáticos). |
| **Spring Boot Actuator** | Expone de forma nativa endpoints de telemetría, salud del sistema (`/actuator/health`) y métricas de rendimiento. |

---

## 2. 📡 Streaming en Tiempo Real — Event-Driven

Herramientas para implementar el envío de datos constante hacia los clientes sin saturar el servidor.

| Tecnología | Descripción |
|---|---|
| **Sinks (Project Reactor)** | Componente interno (`Sinks.many().multicast().onBackpressureBuffer()`) que actúa como una tubería en memoria para capturar transacciones exitosas y distribuirlas a múltiples suscriptores. |
| **Server-Sent Events (SSE)** | Protocolo web nativo (cabecera `text/event-stream`) que mantiene una única conexión HTTP abierta y eficiente para transmitir eventos en vivo desde el servidor al cliente. |

---

## 3. 🔗 Integración y Resiliencia en Microservicios

Tecnologías para comunicarse con otras APIs externas de forma segura y tolerante a fallos.

| Tecnología | Descripción |
|---|---|
| **WebClient** | Cliente HTTP nativo y no bloqueante de WebFlux que reemplaza por completo al antiguo `RestTemplate`. |
| **Resilience4j — Circuit Breaker** | Corta temporalmente la comunicación con un servicio externo si este empieza a fallar, evitando que el microservicio se sature esperando respuestas. |
| **Resilience4j — Retry** | Mecanismo para reintentar automáticamente peticiones HTTP fallidas debido a parpadeos o microcortes de red. |
| **Resilience4j — TimeLimiter** | Configura tiempos de espera máximos (Timeouts) para cancelar solicitudes externas que tarden demasiado en responder. |

---

## 4. 🔍 Trazabilidad y Observabilidad — Estrategia de Logs

Componentes para auditar y rastrear lo que ocurre en un entorno asíncrono donde una sola petición salta entre múltiples hilos.

| Tecnología | Descripción |
|---|---|
| **Log4j2** | Motor de registro de alto rendimiento que sustituye al Logback tradicional. |
| **Plugins de Formato JSON (Jackson/Log4j2)** | Configura cada línea de log como un objeto JSON limpio, listo para ser procesado por herramientas de nube (AWS CloudWatch, ElasticSearch, Grafana). |
| **MDC Reactivo (Mapped Diagnostic Context)** | Técnica para inyectar un `X-Correlation-Id` (ID único de petición) en el flujo reactivo, permitiendo filtrar y seguir el camino exacto de una transacción en los logs. |

---

## 5. 🧪 Pruebas Automatizadas — Testing

| Tecnología | Descripción |
|---|---|
| **StepVerifier (Reactor Test)** | Librería especializada para testear flujos reactivos. Permite verificar paso a paso qué datos emite un `Mono` o un `Flux` y asegurar que completen la ejecución correctamente. |

---

## 6. ✅ Calidad de Código y Auditoría Automática — DevOps

Herramientas que automatizan la revisión del código antes de subirlo a un entorno real.

| Tecnología | Descripción |
|---|---|
| **SonarQube** | Plataforma que analiza estáticamente el código fuente en busca de vulnerabilidades de seguridad, bugs ocultos y malas prácticas (Code Smells). |
| **Checkstyle** | Plugin de Maven que audita la estética del código basándose en las reglas estrictas de Google (formato, espaciados, nombrado de variables). |
| **JaCoCo (Java Code Coverage)** | Mide el porcentaje de cobertura de las pruebas unitarias y permite bloquear la compilación si no se alcanza el mínimo requerido (ej. 70% de cobertura). |

---

## 7. 🐳 Infraestructura y Herramientas de Entorno

Software externo necesario para ejecutar y validar el ecosistema completo.

| Tecnología | Descripción |
|---|---|
| **Maven 3.9+** | Motor de construcción que gestiona las dependencias y ejecuta los ciclos de vida del proyecto (compilación, tests y validaciones de calidad). |
| **Docker / Docker Compose** | Levanta contenedores locales de forma inmediata: **MongoDB** (base de datos real) y **SonarQube** (servidor de auditoría de código). |
| **Postman** | Herramienta cliente para enviar peticiones manuales de prueba (`POST`, `GET`) y conectarse de forma indefinida a escuchar el flujo del stream SSE. |

---

## 📊 Resumen del Stack

```
Total de secciones : 7
Total de tecnologías: ~20
```

| Área | Tecnologías Clave |
|---|---|
| Core Reactivo | Java 21, Spring WebFlux, MongoDB Reactivo |
| Streaming | Sinks, SSE |
| Resiliencia | WebClient, Circuit Breaker, Retry, TimeLimiter |
| Observabilidad | Log4j2, JSON Logs, MDC Reactivo |
| Testing | StepVerifier |
| Calidad | SonarQube, Checkstyle, JaCoCo |
| Infraestructura | Maven, Docker, Postman |

---

> 💡 **Nota:** Este stack está diseñado para sistemas de **alta concurrencia y misión crítica**, donde la resiliencia, la trazabilidad y la calidad del código son requisitos no negociables.
