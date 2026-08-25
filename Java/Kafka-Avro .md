# Kafka con Avro — Flujo producer/consumer

Guía práctica del flujo end-to-end de un evento en Kafka usando **Avro** como formato de serialización, con Spring Boot y Schema Registry.

---

## Escenario (mismo que con JSON)

`ms-prestamos` aprueba un préstamo → publica evento → `ms-notificaciones` manda correo.

- **Productor**: `ms-prestamos` publica el evento
- **Tópico**: `ppel.prestamos.aprobados`
- **Consumidor**: `ms-notificaciones` escucha y manda el correo

---

## Diferencia mental clave respecto a JSON

- **Con JSON**: cada MS tenía su propio POJO escrito a mano.
- **Con Avro**: existe un **archivo `.avsc`** (el schema) que es el contrato compartido, y la clase Java se **autogenera** desde ese archivo.
- Aparece un componente nuevo: el **Schema Registry** (servicio HTTP aparte donde viven los schemas centralizados).

---

## Los 3 actores del juego

```
┌─────────────────────┐     ┌─────────────────────┐     ┌─────────────────────┐
│                     │     │                     │     │                     │
│    TU MICRO         │     │  SCHEMA REGISTRY    │     │       KAFKA         │
│   (ms-prestamos)    │     │                     │     │                     │
│                     │     │                     │     │                     │
│  Corre en TU pod    │     │  Servicio HTTP      │     │  Cluster de brokers │
│  Java + Spring      │     │  aparte             │     │                     │
│                     │     │                     │     │                     │
│  Puerto: 8080       │     │  Puerto: 8081       │     │  Puerto: 9092       │
│                     │     │                     │     │                     │
└─────────────────────┘     └─────────────────────┘     └─────────────────────┘
```

Son 3 servicios distintos, corriendo en 3 lugares distintos. Se comunican por red.

### ¿Qué es el Schema Registry?

Es un **servicio HTTP independiente** (hecho por Confluent). Su única función: **guardar schemas Avro y darles un ID único**.

Es literalmente una API REST:

```
GET  http://schema-registry:8081/subjects
     → devuelve la lista de todos los schemas registrados

GET  http://schema-registry:8081/schemas/ids/42
     → devuelve el schema con ID 42

POST http://schema-registry:8081/subjects/mi-topico-value/versions
     → registra un schema nuevo, devuelve su ID
```

Por dentro guarda:

| ID | Schema Avro |
|----|-------------|
| 1  | `{...schema del evento A...}` |
| 2  | `{...schema del evento B...}` |
| 42 | `{...tu PrestamoAprobadoEvent...}` |

---

## Lado PRODUCER (`ms-prestamos`)

### 1. El schema `.avsc` (el contrato)

Archivo: `src/main/resources/avro/PrestamoAprobadoEvent.avsc`

```json
{
  "type": "record",
  "name": "PrestamoAprobadoEvent",
  "namespace": "pe.com.bcp.ppel.events",
  "fields": [
    { "name": "codigoOperacion", "type": "string" },
    { "name": "correoCliente", "type": "string" },
    { "name": "monto", "type": "double" }
  ]
}
```

Este archivo es la **fuente de verdad** del contrato.

### 2. Dependencias y plugin en `pom.xml`

```xml
<dependencies>
    <dependency>
        <groupId>org.apache.avro</groupId>
        <artifactId>avro</artifactId>
        <version>1.11.3</version>
    </dependency>
    <dependency>
        <groupId>io.confluent</groupId>
        <artifactId>kafka-avro-serializer</artifactId>
        <version>7.5.0</version>
    </dependency>
</dependencies>

<build>
    <plugins>
        <plugin>
            <groupId>org.apache.avro</groupId>
            <artifactId>avro-maven-plugin</artifactId>
            <executions>
                <execution>
                    <goals><goal>schema</goal></goals>
                </execution>
            </executions>
        </plugin>
    </plugins>
</build>
```

### 3. Plugin autogenera la clase Java

Cuando corres `mvn compile`, el plugin lee el `.avsc` y te crea la clase Java automáticamente:

```
target/generated-sources/avro/pe/com/bcp/ppel/events/
    └── PrestamoAprobadoEvent.java
```

**Tú no la escribes**. Tiene getters, setters, builders, y el schema completo guardado adentro:

```java
public class PrestamoAprobadoEvent {

    // ⬇️ EL SCHEMA VIVE DENTRO DE LA CLASE
    public static final Schema SCHEMA$ = new Schema.Parser().parse(
        "{\"type\":\"record\",\"name\":\"PrestamoAprobadoEvent\",...}"
    );

    private String codigoOperacion;
    private String correoCliente;
    private Double monto;

    public static Schema getClassSchema() {
        return SCHEMA$;
    }

    // getters, setters, builders...
}
```

### 4. Configuración (`application.yml`)

```yaml
spring:
  kafka:
    bootstrap-servers: localhost:9092
    producer:
      key-serializer: org.apache.kafka.common.serialization.StringSerializer
      value-serializer: io.confluent.kafka.serializers.KafkaAvroSerializer
      properties:
        schema.registry.url: http://schema-registry:8081
```

Cambian 2 cosas respecto a JSON:
- El `value-serializer` ahora es `KafkaAvroSerializer` (de Confluent).
- Aparece la URL del **Schema Registry**.

### 5. Producer (código casi idéntico)

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

### 6. Caso de uso

```java
PrestamoAprobadoEvent evento = PrestamoAprobadoEvent.newBuilder()
    .setCodigoOperacion("PPEL-001")
    .setCorreoCliente("juan@gmail.com")
    .setMonto(15000.00)
    .build();

producer.publicar(evento);
```

Usa un `builder` (autogenerado por Avro), no `new` y setters.

---

## Qué pasa por debajo cuando llamas `kafkaTemplate.send(...)`

El `KafkaAvroSerializer` hace **4 sub-pasos**:

### a) Extrae el schema del objeto

Como la clase fue autogenerada, tiene el schema adentro:

```java
Schema schemaDelObjeto = evento.getSchema();
// schemaDelObjeto ahora es un objeto Java en memoria
```

Es literalmente el mismo `.avsc` cargado como objeto Java.

### b) Consulta al Schema Registry

Hace una llamada HTTP:

```
POST http://schema-registry:8081/subjects/ppel.prestamos.aprobados-value/versions
Content-Type: application/json

{
  "schema": "{\"type\":\"record\",\"name\":\"PrestamoAprobadoEvent\",...}"
}
```

### c) El Registry responde con un ID

**Escenario A** — Es la primera vez que ve ese schema:
- Lo guarda en su base de datos.
- Le asigna un ID nuevo (ej: `42`).
- Responde: `{ "id": 42 }`

**Escenario B** — Ya lo tenía registrado:
- Responde con el ID que ya tenía: `{ "id": 42 }`

El serializer **cachea** ese ID en memoria. La próxima vez no vuelve a preguntar.

### d) Serializa a bytes binarios con el ID al inicio

Formato final (wire format de Confluent):

```
Byte 0:      0x00           ← byte "mágico" (marca "esto es Avro")
Bytes 1-4:   [id=42]        ← 4 bytes con el schemaId
Bytes 5+:    [valores]      ← datos binarios en orden
```

**Los nombres de los campos NO viajan.** Solo el ID y los valores.

### Cómo se codifica el schemaId en 4 bytes

Un `int` en Java ocupa 4 bytes. Ejemplo con `891`:

```
Decimal:  891
Binario:  00000000 00000000 00000011 01111011
Hex:      0x00     0x00     0x03     0x7B
```

Se coloca así en el array:

```
Posición:  0    1    2    3    4    5   6   7   ...
Byte:     0x00 0x00 0x00 0x03 0x7B 'P' 'P' 'E'  ...
          │    └────────┬────────┘  └─────┬─────┘
          │             │                  │
          │             │                  └── datos
          │             └── el int 891 (4 bytes)
          └── byte mágico
```

### Envía los bytes a Kafka

El serializer entrega los bytes al `KafkaTemplate`, y este los manda al broker. Kafka los guarda tal cual. **Kafka no sabe nada de Avro ni del Registry.** Para Kafka son solo bytes crudos.

---

## Diagrama del flujo del PRODUCER

```
┌───────────────────────────────┐
│      ms-prestamos             │
│                               │
│  1. Objeto Java               │
│     PrestamoAprobadoEvent     │
│          │                    │
│          ▼                    │
│  2. KafkaAvroSerializer       │
│     (extrae schema)           │
│          │                    │
└──────────┼────────────────────┘
           │
           │  HTTP: "¿conoces este schema?"
           ▼
┌───────────────────────────────┐
│    SCHEMA REGISTRY :8081      │
│                               │
│    Guarda schemas             │
│    Devuelve ID = 42           │
└──────────┬────────────────────┘
           │
           │  responde: id=42
           ▼
┌───────────────────────────────┐
│      ms-prestamos             │
│                               │
│  3. Serializa a bytes:        │
│     [0][42][valores binarios] │
│          │                    │
└──────────┼────────────────────┘
           │
           │  TCP: envía bytes
           ▼
┌───────────────────────────────┐
│         KAFKA :9092           │
│                               │
│    Tópico:                    │
│    ppel.prestamos.aprobados   │
│                               │
│    Guarda bytes crudos        │
└───────────────────────────────┘
```

---

## Lado CONSUMER (`ms-notificaciones`)

### 1. Tiene el MISMO `.avsc` en su proyecto

```
ms-notificaciones/
└── src/main/resources/avro/
    └── PrestamoAprobadoEvent.avsc   ← idéntico al del producer
```

Normalmente se comparte vía:
- Un repo de schemas centralizado (`schemas-repo`)
- Una librería/jar interna que ambos MS importan

### 2. Configuración

```yaml
spring:
  kafka:
    bootstrap-servers: localhost:9092
    consumer:
      group-id: ms-notificaciones
      key-deserializer: org.apache.kafka.common.serialization.StringDeserializer
      value-deserializer: io.confluent.kafka.serializers.KafkaAvroDeserializer
      properties:
        schema.registry.url: http://schema-registry:8081
        specific.avro.reader: true
```

`specific.avro.reader: true` le dice: _"deserializa a la clase Java específica generada, no a un objeto genérico"_.

### 3. Listener (código casi idéntico)

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

La diferencia con JSON es que `PrestamoAprobadoEvent` **es la misma clase autogenerada** que en el producer (no una copia hecha a mano).

---

## Qué pasa por debajo cuando llega un mensaje

El `KafkaAvroDeserializer` hace **5 sub-pasos**:

### a) Lee el byte mágico

```java
byte magico = bytes[0]; // 0x00
```

Si no es `0x00`, tira error. Sirve como verificación.

### b) Lee los siguientes 4 bytes (el schemaId)

```java
ByteBuffer buffer = ByteBuffer.wrap(bytes);
byte magico = buffer.get();       // lee bytes[0] → 0x00
int schemaId = buffer.getInt();   // lee bytes[1..4] → 42
```

**El schemaId no se adivina**: está en una posición fija (bytes 1-4) porque así lo dice la convención de Confluent.

### Cómo `getInt()` calcula el número de los 4 bytes

Los 4 bytes se interpretan en **big-endian** (byte más significativo primero):

```
Bytes:    0x00      0x00      0x03      0x7B
          │         │         │         │
          ▼         ▼         ▼         ▼
Peso:  ×16.777.216 ×65.536   ×256      ×1

Cálculo: (0 × 16.777.216) + (0 × 65.536) + (3 × 256) + (123 × 1)
       =  0            +  0           +  768      +  123
       =  891
```

### c) Consulta al Schema Registry

Primero revisa su **cache local**:
- Si tiene el schema 42 → lo usa directamente.
- Si no → llama al Registry:

```
GET http://schema-registry:8081/schemas/ids/42
```

El Registry responde:

```json
{
  "schema": "{\"type\":\"record\",\"name\":\"PrestamoAprobadoEvent\",...}"
}
```

El deserializer parsea ese JSON a un objeto `Schema` y lo **cachea** en memoria.

### d) Sabe cómo interpretar los bytes restantes

Con el schema en la mano:

```
Bytes restantes:
  → Lee un string → "PPEL-001"      → asigna a codigoOperacion
  → Lee un string → "juan@gmail.com" → asigna a correoCliente
  → Lee un double → 15000.00        → asigna a monto
```

### e) Construye el objeto Java

Como configuraste `specific.avro.reader: true`, crea una instancia de la clase específica:

```java
PrestamoAprobadoEvent evento = new PrestamoAprobadoEvent();
evento.setCodigoOperacion("PPEL-001");
evento.setCorreoCliente("juan@gmail.com");
evento.setMonto(15000.00);
return evento;
```

### Spring invoca tu `@KafkaListener` con el objeto listo

```java
@KafkaListener(topics = "ppel.prestamos.aprobados")
public void escuchar(PrestamoAprobadoEvent evento) {
    emailService.enviar(evento.getCorreoCliente(), evento.getMonto());
}
```

Tu código recibe el objeto listo. **No ves nada de bytes, ni schemas, ni IDs.**

---

## Diagrama del flujo del CONSUMER

```
┌─────────────────────────────────┐
│           KAFKA :9092           │
│                                 │
│  Entrega bytes al consumer      │
│  [0][42][valores binarios]      │
└──────────────┬──────────────────┘
               │
               │  bytes crudos
               ▼
┌─────────────────────────────────┐
│      ms-notificaciones          │
│                                 │
│  KafkaAvroDeserializer          │
│                                 │
│  1. Lee byte mágico (0x00)      │
│  2. Lee schemaId = 42           │
│  3. ¿Tengo el schema 42?        │
└──────────────┬──────────────────┘
               │
               │  HTTP: GET /schemas/ids/42
               ▼
┌─────────────────────────────────┐
│     SCHEMA REGISTRY :8081       │
│                                 │
│  Responde con el schema         │
│  { "type":"record",...}         │
└──────────────┬──────────────────┘
               │
               │  schema completo
               ▼
┌─────────────────────────────────┐
│      ms-notificaciones          │
│                                 │
│  KafkaAvroDeserializer          │
│                                 │
│  4. Con el schema, decodifica   │
│     los bytes en orden          │
│  5. Arma el objeto Java         │
│     PrestamoAprobadoEvent       │
│          │                      │
│          ▼                      │
│  Spring invoca @KafkaListener   │
│          │                      │
│          ▼                      │
│  Tu método corre                │
│  emailService.enviar(...)       │
└─────────────────────────────────┘
```

---

## Comparación producer vs consumer

| | Producer | Consumer |
|---|---|---|
| Componente | `KafkaAvroSerializer` | `KafkaAvroDeserializer` |
| Input | Objeto Java | Bytes crudos |
| Output | Bytes crudos | Objeto Java |
| Registry: acción | **Registra** el schema, obtiene ID | **Consulta** el schema por ID |
| Registry: verbo HTTP | POST | GET |
| Cache | ID del schema por objeto | Schema completo por ID |

Son operaciones **espejo**.

---

## Datos importantes sobre el schemaId

### El schemaId identifica al SCHEMA, no al mensaje

Si el producer envía **10 mensajes** del mismo tipo, todos llevan el **mismo schemaId**:

| Mensaje | schemaId | offset (asignado por Kafka) | Datos |
|---------|----------|------------------------------|--------|
| 1       | **42**   | 0                            | PPEL-001, juan@..., 15000 |
| 2       | **42**   | 1                            | PPEL-002, maria@..., 8000 |
| ...     | **42**   | ...                          | ... |
| 10      | **42**   | 9                            | PPEL-010, ana@..., 12000 |

### schemaId vs offset (no confundir)

- **schemaId** → identifica el schema (el molde). Vive en el Schema Registry.
- **offset** → identifica el mensaje. Vive en Kafka. Único por mensaje.

### Mismo schema en distintos tópicos = mismo ID

| Tópico                        | schemaId |
|-------------------------------|----------|
| ppel.prestamos.aprobados      | 42       |
| contabilidad.prestamos        | **42**   |
| reportes.prestamos            | **42**   |

### Schemas distintos = IDs distintos (secuenciales, no aleatorios)

| Tópico                        | Schema                     | schemaId |
|-------------------------------|----------------------------|----------|
| ppel.prestamos.aprobados      | PrestamoAprobadoEvent      | 42       |
| ppel.prestamos.rechazados     | PrestamoRechazadoEvent     | **43**   |
| ppel.desembolsos              | DesembolsoEvent            | **44**   |

### Cuando el schema evoluciona, cambia el ID

Si agregas un campo `tipoCliente` al `.avsc`, el Registry le asigna un nuevo ID:

| Mensaje | schemaId | offset | Datos |
|---------|----------|--------|--------|
| 1       | 42       | 0      | ...schema viejo... |
| 2       | 42       | 1      | ...schema viejo... |
| 11      | **43**   | 10     | ...schema nuevo con tipoCliente... |
| 12      | **43**   | 11     | ...schema nuevo... |

En Kafka **pueden coexistir mensajes con schemas distintos**.

---

## Cómo Avro resuelve los 3 problemas de JSON

### 1. Duplicación de la clase → RESUELTO

Existe **un solo `.avsc`** (fuente de verdad) y ambos MS generan la clase Java desde ese mismo archivo. Imposible desincronizarse.

### 2. Sin contrato fuerte → RESUELTO

El Schema Registry valida en runtime. En build-time, si mandas un campo que no existe, no compila. Además, si intentas cambiar el schema de forma incompatible, el Registry **rechaza el registro**.

### 3. Peso de los mensajes → RESUELTO

Los nombres de campos NO viajan. Solo el `schemaId` (4 bytes) + los valores en binario. Un mensaje de 80 bytes en JSON pesa 25-30 bytes en Avro.

---

## Comparación rápida JSON vs Avro

| Aspecto | JSON | Avro |
|---|---|---|
| Contrato | POJO por MS (duplicado) | `.avsc` compartido |
| Clase Java | Escrita a mano | Autogenerada |
| Serializer | `JsonSerializer` | `KafkaAvroSerializer` |
| Formato en Kafka | Texto legible | Binario + schemaId |
| Peso | Pesado | Compacto |
| Validación | Runtime (tarde) | Build + Registry |
| Componente extra | Ninguno | Schema Registry |
| Debug visual | Fácil (abres y lees) | Necesitas herramienta |

---

## Lo que cambió y lo que NO cambió respecto a JSON

**NO cambió:**
- Tu producer sigue llamando `kafkaTemplate.send(...)` igual.
- Tu listener sigue anotado con `@KafkaListener`.
- La lógica de negocio.

**SÍ cambió:**
- Ahora tienes un `.avsc` en tu proyecto.
- Un plugin genera la clase Java automáticamente.
- La config apunta a `KafkaAvroSerializer/Deserializer` y al Schema Registry.
- Necesitas el Schema Registry corriendo en tu ambiente.

---

## Idea clave para retener

> Avro es "JSON con esteroides": aparece un archivo de schema compartido, la clase se autogenera desde ese schema, los mensajes viajan en binario compacto, y un servicio central (Schema Registry) se encarga de versionar y validar los schemas.

> El Schema Registry es un **servidor HTTP aparte** que actúa como la "biblioteca central" de schemas Avro. Producer y consumer conversan con él por HTTP para registrar/obtener schemas por ID. Kafka **no lo conoce**; es una pieza adicional que orquesta el mundo Avro alrededor de Kafka.
