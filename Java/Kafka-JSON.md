# Kafka con JSON — Flujo clásico producer/consumer

Guía práctica del flujo end-to-end de un evento en Kafka usando JSON como formato de serialización, con Spring Boot.

---

## Escenario

`ms-prestamos` aprueba un préstamo y le avisa a `ms-notificaciones` para que mande un correo al cliente.

- **Productor**: `ms-prestamos` publica el evento
- **Tópico**: `ppel.prestamos.aprobados`
- **Consumidor**: `ms-notificaciones` escucha y manda el correo

---

## Lado PRODUCER (`ms-prestamos`)

### 1. POJO del evento

```java
public class PrestamoAprobadoEvent {
    private String codigoOperacion;
    private String correoCliente;
    private Double monto;
    // getters + setters
}
```

### 2. Configuración (`application.yml`)

```yaml
spring:
  kafka:
    bootstrap-servers: localhost:9092
    producer:
      key-serializer: org.apache.kafka.common.serialization.StringSerializer
      value-serializer: org.springframework.kafka.support.serializer.JsonSerializer
```

> Aquí le dices a Spring: _"cuando yo mande un objeto, usa `JsonSerializer` para convertirlo a bytes"_.

### 3. Producer

```java
@Service
@RequiredArgsConstructor
public class PrestamoEventProducer {

    private final KafkaTemplate<String, PrestamoAprobadoEvent> kafkaTemplate;

    public void publicar(PrestamoAprobadoEvent evento) {
        kafkaTemplate.send("ppel.prestamos.aprobados",
                           evento.getCodigoOperacion(),
                           evento);
    }
}
```

### 4. Caso de uso que lo dispara

```java
PrestamoAprobadoEvent evento = new PrestamoAprobadoEvent();
evento.setCodigoOperacion("PPEL-001");
evento.setCorreoCliente("juan@gmail.com");
evento.setMonto(15000.00);

producer.publicar(evento);
```

---

## Qué pasa por debajo cuando llamas `kafkaTemplate.send(...)`

1. `KafkaTemplate` recibe el objeto.
2. Ve en la config que el serializer del value es `JsonSerializer`.
3. `JsonSerializer` toma el objeto → lo convierte a texto JSON (con Jackson) → convierte ese texto a bytes UTF-8.
4. Arma un `ProducerRecord` con: tópico, key en bytes, value en bytes.
5. Manda ese record por TCP al broker de Kafka.

### Lo que Kafka guarda

Bytes crudos en el tópico `ppel.prestamos.aprobados`. Si los interpretas como texto, se ven así:

```json
{"codigoOperacion":"PPEL-001","correoCliente":"juan@gmail.com","monto":15000.00}
```

---

## Lado CONSUMER (`ms-notificaciones`)

### 1. Su PROPIO POJO (replicado a mano)

```java
public class PrestamoAprobadoEvent {
    private String codigoOperacion;
    private String correoCliente;
    private Double monto;
    // getters + setters
}
```

### 2. Configuración

```yaml
spring:
  kafka:
    bootstrap-servers: localhost:9092
    consumer:
      group-id: ms-notificaciones
      key-deserializer: org.apache.kafka.common.serialization.StringDeserializer
      value-deserializer: org.springframework.kafka.support.serializer.JsonDeserializer
      properties:
        spring.json.trusted.packages: "*"
        spring.json.value.default.type: pe.com.bcp.notificaciones.events.PrestamoAprobadoEvent
```

### 3. Listener

```java
@Component
@RequiredArgsConstructor
public class PrestamoAprobadoListener {

    private final EmailService emailService;

    @KafkaListener(topics = "ppel.prestamos.aprobados")
    public void escuchar(PrestamoAprobadoEvent evento) {
        emailService.enviar(evento.getCorreoCliente(), evento.getMonto());
    }
}
```

---

## Qué pasa por debajo cuando llega un mensaje

1. Kafka le entrega los bytes al consumer.
2. `JsonDeserializer` toma los bytes → los interpreta como texto UTF-8 → Jackson usa ese texto para armar un objeto `PrestamoAprobadoEvent`.
3. Spring invoca tu método `@KafkaListener` pasándole el objeto ya armado.
4. Tu código de negocio corre (manda el correo).

---

## Diagrama mental del flujo completo

```
┌─────────────────┐        ┌────────────┐        ┌──────────────────┐
│  ms-prestamos   │        │   KAFKA    │        │ ms-notificaciones│
│                 │        │            │        │                  │
│  Objeto Java    │        │            │        │                  │
│       │         │        │            │        │                  │
│       ▼         │        │            │        │                  │
│ JsonSerializer  │        │            │        │                  │
│       │         │        │            │        │                  │
│       ▼         │        │            │        │                  │
│    bytes    ────┼───────►│  bytes en  │───────►│      bytes       │
│                 │        │  tópico    │        │        │         │
│                 │        │            │        │        ▼         │
│                 │        │            │        │ JsonDeserializer │
│                 │        │            │        │        │         │
│                 │        │            │        │        ▼         │
│                 │        │            │        │  Objeto Java     │
│                 │        │            │        │        │         │
│                 │        │            │        │        ▼         │
│                 │        │            │        │   Listener       │
└─────────────────┘        └────────────┘        └──────────────────┘
```

---

## Concepto clave: todo son bytes

Kafka **solo guarda bytes** (`byte[]`). Nunca guarda "JSON" ni "Avro" como tal. El serializer es quien decide qué bytes se generan a partir de tu objeto.

### El paso mental del JsonSerializer

```
Objeto Java  →  String JSON  →  bytes UTF-8
```

- **Objeto Java**: la instancia que le pasas al `KafkaTemplate`
- **String JSON**: representación en texto (`{"codigoOperacion":"PPEL-001",...}`)
- **bytes UTF-8**: cada carácter del string codificado como byte (ej: `{` = `123`, `"` = `34`)

Los bytes SON el JSON. No son dos cosas distintas: es la misma información vista de dos maneras (una legible para humanos, otra como secuencia numérica para la computadora).

---

## Los 3 puntos débiles de este approach

### 1. Duplicación de la clase

La clase `PrestamoAprobadoEvent` está duplicada en `ms-prestamos` y `ms-notificaciones`. Si son 5 consumers, la clase vive en **6 lugares diferentes**. Cualquier desincronización es un bug esperando a pasar.

### 2. Sin contrato fuerte

Si el productor renombra `monto` → `montoAprobado`, los consumers **no se enteran** en compile-time. El código sigue compilando, pero en producción reciben un `null` en ese campo y algo explota en runtime.

### 3. Peso del mensaje

Los nombres de campos (`codigoOperacion`, `correoCliente`, `monto`) viajan en **cada** mensaje. Con 1 millón de eventos al día, la palabra `codigoOperacion` viaja por la red 1 millón de veces. Puro desperdicio.

---

## Comparación mental JSON vs Avro (adelanto)

| | JSON | Avro |
|---|---|---|
| Dónde vive el contrato | En el POJO de cada MS | En un `.avsc` compartido |
| Cómo se crea la clase Java | La escribes a mano | Se autogenera |
| Qué viaja por Kafka | Texto JSON en bytes | Bytes binarios + schemaId |
| Validación de contrato | En runtime (tarde) | En build + Schema Registry |
| Peso del mensaje | Pesado | Compacto |
| Servicio extra necesario | Ninguno | Schema Registry |

Estos 3 problemas del approach con JSON son exactamente los que **Avro** resuelve, y por eso se usa tanto en banca (BCP incluido).
