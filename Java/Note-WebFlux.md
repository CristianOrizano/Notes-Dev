# Spring WebFlux — Guía de Referencia
 
> Guía compacta para recordar, aprender o enseñar WebFlux desde cero hasta nivel profesional.
 
---
 
## Índice
1. [Programación Reactiva — Fundamentos](#1-programación-reactiva--fundamentos)
2. [Reactive Streams — Estándar](#2-reactive-streams--estándar)
3. [Project Reactor](#3-project-reactor)
4. [Mono y Flux](#4-mono-y-flux)
5. [Operadores principales](#5-operadores-principales)
6. [Spring WebFlux](#6-spring-webflux)
7. [Router Functions vs Anotaciones](#7-router-functions-vs-anotaciones)
8. [WebClient](#8-webclient)
9. [R2DBC — Base de datos reactiva](#9-r2dbc--base-de-datos-reactiva)
10. [MongoDB Reactivo](#10-mongodb-reactivo)
11. [Manejo de errores](#11-manejo-de-errores)
12. [Backpressure](#12-backpressure)
13. [Scheduler y hilos](#13-scheduler-y-hilos)
14. [Seguridad con WebFlux](#14-seguridad-con-webflux)
15. [Testing reactivo](#15-testing-reactivo)
16. [WebFlux vs MVC — ¿Cuándo usar cada uno?](#16-webflux-vs-mvc--cuándo-usar-cada-uno)
17. [Dependencias Maven/Gradle](#17-dependencias-mavengra dle)
---
 
## 1. Programación Reactiva — Fundamentos
 
**Qué es:** paradigma de programación basado en flujos de datos asíncronos y propagación de cambios.
 
**Para qué sirve:** manejar muchas solicitudes concurrentes sin bloquear hilos, ideal para sistemas de alta demanda.
 
| Imperativa | Reactiva |
|---|---|
| Secuencial y bloqueante | Asíncrona y no bloqueante |
| 1 hilo por petición | Pocos hilos, muchas conexiones |
| `List<User>` | `Flux<User>` |
 
```java
// Imperativa — bloquea el hilo
List<User> users = userRepository.findAll(); // espera aquí
 
// Reactiva — no bloquea
Flux<User> users = userRepository.findAll(); // se suscribe y reacciona
```
 
---
 
## 2. Reactive Streams — Estándar
 
**Qué es:** especificación estándar de la JVM para programación reactiva (java.util.concurrent.Flow).
 
**Para qué sirve:** define el contrato que deben cumplir todas las librerías reactivas (Reactor, RxJava, etc.).
 
**4 interfaces clave:**
 
| Interfaz | Rol |
|---|---|
| `Publisher<T>` | Produce y emite datos |
| `Subscriber<T>` | Consume los datos |
| `Subscription` | Vínculo entre ambos, controla el flujo |
| `Processor<T,R>` | Es Publisher y Subscriber a la vez |
 
> En Spring WebFlux tú trabajas con `Mono` y `Flux` (que implementan `Publisher`). El resto lo maneja el framework automáticamente.
 
---
 
## 3. Project Reactor
 
**Qué es:** librería de programación reactiva para la JVM, creada por Pivotal/VMware.
 
**Para qué sirve:** es la base de Spring WebFlux. Implementa la especificación Reactive Streams y provee `Mono` y `Flux`.
 
```
Reactive Streams (estándar)
       ↓
Project Reactor (implementación)
       ↓
Spring WebFlux (framework web)
```
 
---
 
## 4. Mono y Flux
 
**Qué son:** los dos tipos principales con los que trabajas en WebFlux.
 
### `Mono<T>` — 0 o 1 elemento
 
**Para qué:** resultado único (buscar por ID, guardar, actualizar, eliminar).
 
```java
Mono<User> user = userRepository.findById(1L);
 
Mono<User> saved = userRepository.save(new User("Cristian"));
 
Mono<Void> deleted = userRepository.deleteById(1L);
```
 
### `Flux<T>` — 0 a N elementos
 
**Para qué:** listas, streams continuos, respuestas paginadas.
 
```java
Flux<User> users = userRepository.findAll();
 
Flux<Integer> numbers = Flux.just(1, 2, 3, 4, 5);
 
Flux<Long> interval = Flux.interval(Duration.ofSeconds(1)); // stream infinito
```
 
### Ciclo de vida
 
```java
Flux.just("A", "B", "C")
    .subscribe(
        item  -> System.out.println("Recibí: " + item),  // onNext
        error -> System.out.println("Error: " + error),  // onError
        ()    -> System.out.println("Completado")         // onComplete
    );
```
 
> **Importante:** sin `.subscribe()` no pasa nada. Los flujos son **lazy** (perezosos).
 
---
 
## 5. Operadores principales
 
### Transformación
 
**`map`** — transforma cada elemento de forma síncrona.
```java
Flux.just(1, 2, 3)
    .map(n -> n * 2)  // 2, 4, 6
```
 
**`flatMap`** — transforma cada elemento en otro Publisher (para operaciones asíncronas).
```java
Flux.just(1L, 2L, 3L)
    .flatMap(id -> userRepository.findById(id))  // llama a BD por cada ID
```
 
**`map` vs `flatMap`:**
- `map`: `T → R` (síncrono)
- `flatMap`: `T → Mono<R>` o `T → Flux<R>` (asíncrono, aplana el resultado)
---
 
### Filtrado
 
**`filter`** — deja pasar solo los elementos que cumplen la condición.
```java
Flux.just(1, 2, 3, 4)
    .filter(n -> n % 2 == 0)  // 2, 4
```
 
**`take(n)`** — toma solo los primeros N elementos.
```java
Flux.range(1, 100).take(5)  // 1, 2, 3, 4, 5
```
 
**`distinct`** — elimina duplicados.
```java
Flux.just("a", "b", "a").distinct()  // "a", "b"
```
 
---
 
### Combinación
 
**`zip`** — combina elementos de dos flujos en pares (espera que ambos emitan).
```java
Flux<String> names  = Flux.just("Ana", "Bob");
Flux<Integer> ages  = Flux.just(25, 30);
 
Flux.zip(names, ages, (name, age) -> name + " tiene " + age)
// "Ana tiene 25", "Bob tiene 30"
```
 
**`merge`** — mezcla varios flujos manteniendo el orden de llegada (no espera).
```java
Flux.merge(flux1, flux2)
```
 
**`concat`** — ejecuta los flujos en secuencia (uno termina, empieza el otro).
```java
Flux.concat(flux1, flux2)
```
 
---
 
### Efectos secundarios (sin modificar el flujo)
 
**`doOnNext`** — ejecuta una acción por cada elemento (ej. logging), sin alterar el flujo.
```java
Flux.just(1, 2, 3)
    .doOnNext(n -> log.info("Procesando: {}", n))
    .subscribe();
```
 
**`doFinally`** — se ejecuta al finalizar el flujo (éxito, error o cancelación).
```java
flux.doFinally(signal -> log.info("Flujo terminó con: {}", signal))
```
 
**`doOnError`** — ejecuta una acción cuando ocurre un error (sin recuperarlo).
```java
flux.doOnError(e -> log.error("Ocurrió error: {}", e.getMessage()))
```
 
---
 
### Manejo de errores
 
**`onErrorReturn`** — retorna un valor por defecto si hay error.
```java
mono.onErrorReturn(new User("default"))
```
 
**`onErrorResume`** — cambia a otro Publisher si hay error.
```java
mono.onErrorResume(e -> Mono.just(new User("fallback")))
```
 
**`retry(n)`** — reintenta N veces antes de fallar.
```java
mono.retry(3)
```
 
---
 
## 6. Spring WebFlux
 
**Qué es:** módulo de Spring para construir APIs REST no bloqueantes y reactivas.
 
**Para qué sirve:** manejar alta concurrencia con pocos hilos. Usa Netty como servidor por defecto (no Tomcat).
 
### Controller con anotaciones (estilo MVC)
 
```java
@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
public class UserController {
 
    private final UserService userService;
 
    @GetMapping
    public Flux<UserDto> findAll() {
        return userService.findAll();
    }
 
    @GetMapping("/{id}")
    public Mono<ResponseEntity<UserDto>> findById(@PathVariable Long id) {
        return userService.findById(id)
                .map(ResponseEntity::ok)
                .defaultIfEmpty(ResponseEntity.notFound().build());
    }
 
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Mono<UserDto> save(@RequestBody @Valid Mono<UserDto> dto) {
        return dto.flatMap(userService::save);
    }
 
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public Mono<Void> delete(@PathVariable Long id) {
        return userService.deleteById(id);
    }
}
```
 
---
 
## 7. Router Functions vs Anotaciones
 
**Qué es:** alternativa funcional al estilo `@RestController` para definir rutas.
 
**Para qué sirve:** separar rutas y lógica de forma más funcional y testeable.
 
```java
// Handler
@Component
public class UserHandler {
    public Mono<ServerResponse> findAll(ServerRequest req) {
        return ServerResponse.ok()
                .body(userService.findAll(), UserDto.class);
    }
}
 
// Router
@Configuration
public class UserRouter {
    @Bean
    public RouterFunction<ServerResponse> routes(UserHandler handler) {
        return RouterFunctions.route()
                .GET("/users", handler::findAll)
                .POST("/users", handler::save)
                .build();
    }
}
```
 
> Para APIs simples → usa anotaciones. Para mayor control o testing unitario de rutas → usa Router Functions.
 
---
 
## 8. WebClient
 
**Qué es:** cliente HTTP reactivo de Spring WebFlux (reemplaza a `RestTemplate`).
 
**Para qué sirve:** hacer llamadas HTTP a otros servicios sin bloquear el hilo.
 
```java
WebClient client = WebClient.builder()
        .baseUrl("https://api.example.com")
        .defaultHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
        .build();
 
// GET — lista
Flux<UserDto> users = client.get()
        .uri("/users")
        .retrieve()
        .bodyToFlux(UserDto.class);
 
// GET — uno
Mono<UserDto> user = client.get()
        .uri("/users/{id}", 1L)
        .retrieve()
        .bodyToMono(UserDto.class);
 
// POST
Mono<UserDto> created = client.post()
        .uri("/users")
        .bodyValue(new UserDto("Cristian"))
        .retrieve()
        .bodyToMono(UserDto.class);
```
 
> `RestTemplate` es bloqueante → solo para Spring MVC. `WebClient` es no bloqueante → para WebFlux (y también se puede usar en MVC si se necesita).
 
---
 
## 9. R2DBC — Base de datos reactiva
 
**Qué es:** Reactive Relational Database Connectivity. Driver reactivo para bases de datos relacionales.
 
**Para qué sirve:** acceder a PostgreSQL, MySQL, etc. de forma no bloqueante (JPA/JDBC son bloqueantes).
 
**Dependencias (PostgreSQL):**
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-r2dbc</artifactId>
</dependency>
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>r2dbc-postgresql</artifactId>
</dependency>
```
 
**application.yml:**
```yaml
spring:
  r2dbc:
    url: r2dbc:postgresql://localhost:5432/mydb
    username: postgres
    password: secret
```
 
**Repository:**
```java
public interface UserRepository extends ReactiveCrudRepository<User, Long> {
    Flux<User> findByEmail(String email);
    Mono<User> findByUsername(String username);
}
```
 
> `ReactiveCrudRepository` retorna `Mono` y `Flux` en lugar de `Optional` y `List`.
 
---
 
## 10. MongoDB Reactivo
 
**Qué es:** integración de Spring Data con MongoDB de forma reactiva.
 
**Para qué sirve:** acceder a MongoDB sin bloquear hilos (su driver ya es asíncrono por naturaleza).
 
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-mongodb-reactive</artifactId>
</dependency>
```
 
```java
public interface ProductRepository extends ReactiveMongoRepository<Product, String> {
    Flux<Product> findByCategory(String category);
}
```
 
> MongoDB reactivo es más directo que R2DBC porque su driver nativo ya soporta operaciones asíncronas.
 
---
 
## 11. Manejo de errores
 
**Qué es:** estrategias para capturar y manejar errores en flujos reactivos.
 
**Para qué sirve:** no romper el flujo por un error y dar respuestas controladas al cliente.
 
### A nivel de operador
```java
// Valor por defecto
mono.onErrorReturn(new UserDto());
 
// Flujo alternativo
mono.onErrorResume(e -> Mono.just(new UserDto("fallback")));
 
// Lanzar error personalizado
mono.onErrorMap(e -> new UserNotFoundException("No encontrado"));
```
 
### A nivel global con `@ControllerAdvice`
```java
@RestControllerAdvice
public class GlobalExceptionHandler {
 
    @ExceptionHandler(UserNotFoundException.class)
    public Mono<ResponseEntity<ErrorResponse>> handleNotFound(UserNotFoundException ex) {
        return Mono.just(ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(new ErrorResponse(ex.getMessage())));
    }
}
```
 
---
 
## 12. Backpressure
 
**Qué es:** mecanismo para que el consumidor controle cuántos elementos recibe del productor.
 
**Para qué sirve:** evitar que un Subscriber se sature si el Publisher emite más rápido de lo que puede procesar.
 
```java
// El Subscriber pide solo 10 elementos a la vez
Flux.range(1, 1000)
    .subscribe(new BaseSubscriber<Integer>() {
        @Override
        protected void hookOnSubscribe(Subscription subscription) {
            request(10); // pide 10 al inicio
        }
 
        @Override
        protected void hookOnNext(Integer value) {
            System.out.println(value);
            request(1); // pide 1 más por cada procesado
        }
    });
```
 
**Estrategias cuando no puedes controlar el upstream:**
```java
flux.onBackpressureBuffer(100)  // buffer de hasta 100 elementos
flux.onBackpressureDrop()       // descarta elementos que no puede procesar
flux.onBackpressureLatest()     // solo mantiene el último elemento
```
 
---
 
## 13. Scheduler y hilos
 
**Qué es:** mecanismo para controlar en qué hilo se ejecuta cada parte del flujo.
 
**Para qué sirve:** separar operaciones bloqueantes (archivos, JDBC) del event loop reactivo.
 
| Scheduler | Uso |
|---|---|
| `Schedulers.parallel()` | Operaciones intensivas en CPU |
| `Schedulers.boundedElastic()` | Operaciones bloqueantes (I/O, JDBC legacy) |
| `Schedulers.single()` | Un solo hilo reutilizable |
 
```java
// publishOn — cambia el scheduler para lo que viene después
Flux.just(1, 2, 3)
    .publishOn(Schedulers.parallel())
    .map(n -> n * 2)  // se ejecuta en hilo parallel
 
// subscribeOn — cambia el scheduler desde el origen
Flux.fromCallable(() -> blockingDatabaseCall())
    .subscribeOn(Schedulers.boundedElastic())  // la llamada bloqueante va aquí
```
 
> Regla: si tienes código bloqueante (JDBC, archivos), usa `subscribeOn(Schedulers.boundedElastic())` para no bloquear el event loop.
 
---
 
## 14. Seguridad con WebFlux
 
**Qué es:** integración de Spring Security con el modelo reactivo.
 
**Para qué sirve:** autenticación y autorización en aplicaciones WebFlux (usa `SecurityWebFilterChain` en lugar de `HttpSecurity`).
 
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>
```
 
```java
@Configuration
@EnableWebFluxSecurity
public class SecurityConfig {
 
    @Bean
    public SecurityWebFilterChain filterChain(ServerHttpSecurity http) {
        return http
            .csrf(ServerHttpSecurity.CsrfSpec::disable)
            .authorizeExchange(auth -> auth
                .pathMatchers("/public/**").permitAll()
                .anyExchange().authenticated()
            )
            .httpBasic(Customizer.withDefaults())
            .build();
    }
}
```
 
**Para JWT:** se usa `ReactiveJwtDecoder` y `ServerHttpSecurity.oauth2ResourceServer()`.
 
> La diferencia clave: en MVC usas `HttpSecurity`, en WebFlux usas `ServerHttpSecurity` y `SecurityWebFilterChain`.
 
---
 
## 15. Testing reactivo
 
**Qué es:** `StepVerifier`, la herramienta principal para testear `Mono` y `Flux`.
 
**Para qué sirve:** verificar paso a paso lo que emite un flujo reactivo, incluyendo errores y completados.
 
```xml
<dependency>
    <groupId>io.projectreactor</groupId>
    <artifactId>reactor-test</artifactId>
    <scope>test</scope>
</dependency>
```
 
```java
// Test de Flux
@Test
void testFlux() {
    Flux<Integer> flux = Flux.just(1, 2, 3);
 
    StepVerifier.create(flux)
            .expectNext(1)
            .expectNext(2)
            .expectNext(3)
            .verifyComplete();  // verifica que completó correctamente
}
 
// Test de error
@Test
void testError() {
    Mono<User> mono = Mono.error(new RuntimeException("Error de prueba"));
 
    StepVerifier.create(mono)
            .expectErrorMessage("Error de prueba")
            .verify();
}
```
 
**WebTestClient** — para testear endpoints HTTP de WebFlux:
```java
@WebFluxTest(UserController.class)
class UserControllerTest {
 
    @Autowired
    private WebTestClient webTestClient;
 
    @Test
    void findAll() {
        webTestClient.get().uri("/users")
                .exchange()
                .expectStatus().isOk()
                .expectBodyList(UserDto.class)
                .hasSize(3);
    }
}
```
 
---
 
## 16. WebFlux vs MVC — ¿Cuándo usar cada uno?
 
| Criterio | Spring MVC | Spring WebFlux |
|---|---|---|
| Modelo | Bloqueante (Servlet) | No bloqueante (Netty) |
| Hilos | 1 por petición | Pocos, compartidos |
| Base de datos | JPA/JDBC | R2DBC / MongoDB Reactivo |
| Cliente HTTP | `RestTemplate` | `WebClient` |
| Ideal para | CRUD tradicional, equipos sin experiencia reactiva | Microservicios, streaming, alta concurrencia |
| Curva de aprendizaje | Baja | Alta |
 
**Usar WebFlux cuando:**
- Tienes muchas conexiones simultáneas (chat, notificaciones, streaming).
- Consumes APIs externas (microservicios con WebClient).
- Usas MongoDB o necesitas R2DBC.
- Quieres aprovechar SSE (Server-Sent Events) o WebSockets reactivos.
**Quedarse en MVC cuando:**
- El equipo no conoce programación reactiva.
- Tienes dependencias bloqueantes que no puedes reemplazar (JDBC, librerías legacy).
- La aplicación es un CRUD simple sin alta concurrencia.
---
 
## 17. Dependencias Maven/Gradle
 
### pom.xml (Maven)
```xml
<!-- WebFlux -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-webflux</artifactId>
</dependency>
 
<!-- R2DBC + PostgreSQL -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-r2dbc</artifactId>
</dependency>
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>r2dbc-postgresql</artifactId>
</dependency>
 
<!-- MongoDB Reactivo -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-mongodb-reactive</artifactId>
</dependency>
 
<!-- Seguridad -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>
 
<!-- Testing -->
<dependency>
    <groupId>io.projectreactor</groupId>
    <artifactId>reactor-test</artifactId>
    <scope>test</scope>
</dependency>
```
 
---
 
## Resumen visual del stack
 
```
                    ┌──────────────────────────────┐
                    │       Tu Aplicación           │
                    │  Controllers / Handlers       │
                    │  Services (Mono / Flux)       │
                    │  Repositories (R2DBC/Mongo)   │
                    └────────────┬─────────────────┘
                                 │
                    ┌────────────▼─────────────────┐
                    │       Spring WebFlux          │
                    │  (Framework web reactivo)     │
                    └────────────┬─────────────────┘
                                 │
                    ┌────────────▼─────────────────┐
                    │       Project Reactor         │
                    │  Mono<T>  /  Flux<T>          │
                    └────────────┬─────────────────┘
                                 │
                    ┌────────────▼─────────────────┐
                    │     Reactive Streams          │
                    │  Publisher / Subscriber       │
                    └────────────┬─────────────────┘
                                 │
                    ┌────────────▼─────────────────┐
                    │       Netty (servidor)        │
                    │  Event Loop — no bloqueante   │
                    └──────────────────────────────┘
``
