# Quarkus — Guía de Referencia
 
> Guía compacta para recordar, aprender o enseñar Quarkus desde cero hasta nivel semi senior.
 
---
 
## Índice
1. [¿Qué es Quarkus?](#1-qué-es-quarkus)
2. [Quarkus vs Spring Boot](#2-quarkus-vs-spring-boot)
3. [Estructura del proyecto](#3-estructura-del-proyecto)
4. [Configuración — application.properties](#4-configuración--applicationproperties)
5. [REST con JAX-RS](#5-rest-con-jax-rs)
6. [Inyección de dependencias — CDI](#6-inyección-de-dependencias--cdi)
7. [Panache — ORM](#7-panache--orm)
8. [Panache Repository Pattern](#8-panache-repository-pattern)
9. [Validación](#9-validación)
10. [Manejo de errores](#10-manejo-de-errores)
11. [REST Client (llamadas HTTP)](#11-rest-client-llamadas-http)
12. [Seguridad y JWT](#12-seguridad-y-jwt)
13. [Testing con QuarkusTest](#13-testing-con-quarkustest)
14. [Native Build](#14-native-build)
15. [Reactividad con Mutiny](#15-reactividad-con-mutiny)
16. [Dependencias principales](#16-dependencias-principales)
---
 
## 1. ¿Qué es Quarkus?
 
**Qué es:** framework Java para construir aplicaciones cloud-native, diseñado para arrancar muy rápido y consumir poca memoria.
 
**Para qué sirve:** microservicios y aplicaciones serverless donde el tiempo de arranque y el consumo de RAM importan. Su diferencial es que puede compilarse a **binario nativo** con GraalVM.
 
**Sus pilares:**
- Arranque ultrarrápido (milisegundos vs segundos de Spring)
- Bajo consumo de memoria
- Developer Experience: recarga en caliente (`quarkus dev`)
- Compatible con estándares Jakarta EE: JAX-RS, CDI, JPA
---
 
## 2. Quarkus vs Spring Boot
 
| Criterio | Spring Boot | Quarkus |
|---|---|---|
| Arranque | ~2-5 seg | ~0.1-0.5 seg |
| Memoria RAM | Mayor | Mucho menor |
| Anotaciones REST | `@RestController` | `@Path` (JAX-RS) |
| ORM | JPA + Hibernate | Panache (sobre Hibernate) |
| Inyección | `@Autowired` / `@Bean` | CDI (`@Inject`) |
| Native build | No nativo | Sí, con GraalVM |
| Ecosistema | Enorme | Creciendo |
| Popularidad en Perú | Alta | Nicho |
 
> Si ya sabes Spring Boot, Quarkus se aprende rápido. Los conceptos son los mismos, cambian las anotaciones.
 
---
 
## 3. Estructura del proyecto
 
```
my-quarkus-app/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/example/
│   │   │       ├── controller/   (Resources — equivalente a Controllers)
│   │   │       ├── service/
│   │   │       ├── repository/
│   │   │       └── model/
│   │   └── resources/
│   │       └── application.properties
│   └── test/
│       └── java/
├── pom.xml
```
 
**Crear proyecto desde cero:**
```bash
# Desde CLI
mvn io.quarkus.platform:quarkus-maven-plugin:create \
  -DprojectGroupId=com.example \
  -DprojectArtifactId=my-app \
  -Dextensions="rest-jackson,hibernate-orm-panache,jdbc-postgresql"
 
# O desde: https://code.quarkus.io (equivalente a start.spring.io)
```
 
**Modo desarrollo (con hot reload):**
```bash
./mvnw quarkus:dev
```
 
---
 
## 4. Configuración — application.properties
 
**Qué es:** archivo central de configuración de Quarkus (equivalente a `application.yml` de Spring).
 
**Para qué sirve:** definir puertos, base de datos, propiedades custom, perfiles de entorno.
 
```properties
# Puerto
quarkus.http.port=8080
 
# Base de datos
quarkus.datasource.db-kind=postgresql
quarkus.datasource.username=postgres
quarkus.datasource.password=secret
quarkus.datasource.jdbc.url=jdbc:postgresql://localhost:5432/mydb
 
# Hibernate
quarkus.hibernate-orm.database.generation=update
quarkus.hibernate-orm.log.sql=true
 
# Propiedades custom
app.mensaje=Hola desde Quarkus
```
 
**Perfiles de entorno:**
```properties
# Se activa con -Dquarkus.profile=prod
%prod.quarkus.datasource.jdbc.url=jdbc:postgresql://prod-server:5432/mydb
%dev.quarkus.datasource.jdbc.url=jdbc:postgresql://localhost:5432/mydb_dev
%test.quarkus.datasource.jdbc.url=jdbc:postgresql://localhost:5432/mydb_test
```
 
**Inyectar propiedades custom:**
```java
@ConfigProperty(name = "app.mensaje")
String mensaje;
 
@ConfigProperty(name = "app.limite", defaultValue = "10")
int limite;
```
 
---
 
## 5. REST con JAX-RS
 
**Qué es:** estándar Jakarta EE para construir APIs REST. Quarkus lo implementa con RESTEasy.
 
**Para qué sirve:** definir endpoints HTTP (equivalente a `@RestController` de Spring).
 
```java
@Path("/users")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class UserResource {
 
    @Inject
    UserService userService;
 
    // GET /users
    @GET
    public List<UserDto> findAll() {
        return userService.findAll();
    }
 
    // GET /users/1
    @GET
    @Path("/{id}")
    public Response findById(@PathParam("id") Long id) {
        return userService.findById(id)
                .map(user -> Response.ok(user).build())
                .orElse(Response.status(Response.Status.NOT_FOUND).build());
    }
 
    // POST /users
    @POST
    @ResponseStatus(201)
    public Response save(@Valid UserDto dto) {
        UserDto saved = userService.save(dto);
        return Response.status(Response.Status.CREATED).entity(saved).build();
    }
 
    // PUT /users/1
    @PUT
    @Path("/{id}")
    public UserDto update(@PathParam("id") Long id, @Valid UserDto dto) {
        return userService.update(id, dto);
    }
 
    // DELETE /users/1
    @DELETE
    @Path("/{id}")
    @ResponseStatus(204)
    public Response delete(@PathParam("id") Long id) {
        userService.delete(id);
        return Response.noContent().build();
    }
}
```
 
**Equivalencias Spring → Quarkus:**
 
| Spring | Quarkus (JAX-RS) |
|---|---|
| `@RestController` | `@Path` |
| `@GetMapping` | `@GET` |
| `@PostMapping` | `@POST` |
| `@PutMapping` | `@PUT` |
| `@DeleteMapping` | `@DELETE` |
| `@PathVariable` | `@PathParam` |
| `@RequestParam` | `@QueryParam` |
| `@RequestBody` | parámetro directo |
 
**Query params:**
```java
@GET
public List<UserDto> findByName(@QueryParam("name") String name,
                                 @QueryParam("page") @DefaultValue("0") int page) {
    return userService.findByName(name, page);
}
```
 
---
 
## 6. Inyección de dependencias — CDI
 
**Qué es:** Context and Dependency Injection, estándar Jakarta EE para IoC (equivalente al contenedor de Spring).
 
**Para qué sirve:** inyectar beans/servicios entre clases sin instanciarlos manualmente.
 
```java
// Definir un bean
@ApplicationScoped  // equivalente a @Service / @Component de Spring
public class UserService {
 
    @Inject
    UserRepository userRepository;
 
    public List<UserDto> findAll() {
        return userRepository.listAll()
                .stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }
}
```
 
**Scopes disponibles:**
 
| Scope | Equivalente Spring | Cuándo usar |
|---|---|---|
| `@ApplicationScoped` | `@Component` / `@Service` | La mayoría de beans — una sola instancia |
| `@RequestScoped` | `@RequestScope` | Una instancia por petición HTTP |
| `@Singleton` | `@Bean` singleton | Similar a ApplicationScoped, sin proxy |
| `@Dependent` | — | Nueva instancia cada vez que se inyecta |
 
> En Quarkus casi siempre usas `@ApplicationScoped`. Es el equivalente directo de `@Service` en Spring.
 
**Constructor injection (recomendado):**
```java
@ApplicationScoped
public class UserService {
 
    private final UserRepository repository;
 
    @Inject  // puede omitirse si solo hay un constructor
    public UserService(UserRepository repository) {
        this.repository = repository;
    }
}
```
 
---
 
## 7. Panache — ORM
 
**Qué es:** capa de abstracción de Quarkus sobre Hibernate/JPA que simplifica el acceso a datos.
 
**Para qué sirve:** hacer CRUD sin escribir queries básicos, similar a Spring Data JPA pero con dos estilos: Active Record y Repository.
 
### Estilo Active Record (la entidad tiene los métodos)
 
```java
@Entity
@Table(name = "users")
public class User extends PanacheEntity {  // PanacheEntity ya trae el campo id (Long)
 
    public String name;
    public String email;
 
    // Métodos estáticos de consulta van aquí
    public static List<User> findByName(String name) {
        return list("name", name);
    }
 
    public static Optional<User> findByEmail(String email) {
        return find("email", email).firstResultOptional();
    }
}
```
 
**Usando la entidad:**
```java
// Listar todos
List<User> users = User.listAll();
 
// Buscar por ID
User user = User.findById(1L);
 
// Buscar con condición
List<User> users = User.list("name = ?1 and email like ?2", "Cristian", "%@gmail%");
 
// Guardar
User user = new User();
user.name = "Cristian";
user.persist();  // INSERT
 
// Actualizar
user.name = "Cristian Orizano";
user.persist();  // UPDATE (si ya tiene ID)
 
// Eliminar
user.delete();
 
// Contar
long count = User.count();
 
// Eliminar con condición
User.delete("name", "Cristian");
```
 
**Entidad con UUID:**
```java
@Entity
public class User extends PanacheEntityBase {  // Base sin ID predefinido
 
    @Id
    @GeneratedValue
    public UUID id;
 
    public String name;
}
```
 
---
 
## 8. Panache Repository Pattern
 
**Qué es:** alternativa al Active Record donde la lógica de BD va en una clase Repository separada.
 
**Para qué sirve:** separar responsabilidades — la entidad solo es el modelo, el repository maneja el acceso a datos. Más parecido a Spring Data.
 
```java
// Entidad limpia (sin métodos)
@Entity
public class User {
 
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    private String email;
 
    // getters y setters / lombok
}
 
// Repository
@ApplicationScoped
public class UserRepository implements PanacheRepository<User> {
 
    public List<User> findByName(String name) {
        return list("name", name);
    }
 
    public Optional<User> findByEmail(String email) {
        return find("email", email).firstResultOptional();
    }
 
    public List<User> findActive() {
        return list("active = ?1 order by name", true);
    }
}
```
 
**Usando el repository:**
```java
@ApplicationScoped
public class UserService {
 
    @Inject
    UserRepository userRepository;
 
    public List<User> findAll() {
        return userRepository.listAll();
    }
 
    @Transactional
    public User save(User user) {
        userRepository.persist(user);
        return user;
    }
 
    @Transactional
    public void delete(Long id) {
        userRepository.deleteById(id);
    }
}
```
 
> `@Transactional` en Quarkus funciona igual que en Spring. Va en el Service, no en el Resource.
 
---
 
## 9. Validación
 
**Qué es:** integración de Bean Validation (Jakarta Validation) con Quarkus.
 
**Para qué sirve:** validar datos de entrada en los endpoints automáticamente.
 
```xml
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-hibernate-validator</artifactId>
</dependency>
```
 
**DTO con validaciones:**
```java
public class UserDto {
 
    @NotBlank(message = "El nombre es obligatorio")
    public String name;
 
    @NotBlank
    @Email(message = "Email inválido")
    public String email;
 
    @Min(value = 18, message = "Debe ser mayor de edad")
    public int age;
}
```
 
**En el Resource:**
```java
@POST
public Response save(@Valid UserDto dto) {  // @Valid activa la validación
    return Response.status(201).entity(userService.save(dto)).build();
}
```
 
**Manejo de errores de validación (automático con Quarkus):**
Quarkus retorna automáticamente `400 Bad Request` con detalles del error. Para personalizar la respuesta, usa `@ServerExceptionMapper`.
 
---
 
## 10. Manejo de errores
 
**Qué es:** mecanismo para capturar excepciones y retornar respuestas HTTP controladas.
 
**Para qué sirve:** no exponer stack traces al cliente y dar respuestas consistentes.
 
**Excepción custom:**
```java
public class UserNotFoundException extends RuntimeException {
    public UserNotFoundException(Long id) {
        super("Usuario con ID " + id + " no encontrado");
    }
}
```
 
**Exception Mapper (equivalente a `@ControllerAdvice` de Spring):**
```java
@Provider  // registra el mapper automáticamente
public class UserNotFoundMapper implements ExceptionMapper<UserNotFoundException> {
 
    @Override
    public Response toResponse(UserNotFoundException ex) {
        return Response.status(Response.Status.NOT_FOUND)
                .entity(new ErrorResponse(ex.getMessage()))
                .build();
    }
}
```
 
**Con la anotación moderna de Quarkus REST:**
```java
@ServerExceptionMapper
public RestResponse<ErrorResponse> handleNotFound(UserNotFoundException ex) {
    return RestResponse.status(Response.Status.NOT_FOUND,
            new ErrorResponse(ex.getMessage()));
}
```
 
**DTO de error:**
```java
public class ErrorResponse {
    public String message;
    public int status;
 
    public ErrorResponse(String message, int status) {
        this.message = message;
        this.status = status;
    }
}
```
 
---
 
## 11. REST Client (llamadas HTTP)
 
**Qué es:** cliente HTTP declarativo de Quarkus para consumir APIs externas.
 
**Para qué sirve:** llamar a otros microservicios o APIs REST de forma simple (equivalente a Feign en Spring).
 
```xml
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-rest-client-jackson</artifactId>
</dependency>
```
 
**Definir el cliente (solo una interfaz):**
```java
@RegisterRestClient(configKey = "user-api")
@Path("/users")
public interface UserClient {
 
    @GET
    List<UserDto> findAll();
 
    @GET
    @Path("/{id}")
    UserDto findById(@PathParam("id") Long id);
 
    @POST
    UserDto save(UserDto dto);
}
```
 
**Configurar la URL en application.properties:**
```properties
quarkus.rest-client.user-api.url=https://api.example.com
quarkus.rest-client.user-api.scope=javax.inject.Singleton
```
 
**Inyectar y usar:**
```java
@ApplicationScoped
public class OrderService {
 
    @Inject
    @RestClient
    UserClient userClient;
 
    public UserDto getUser(Long id) {
        return userClient.findById(id);
    }
}
```
 
---
 
## 12. Seguridad y JWT
 
**Qué es:** integración de autenticación y autorización en Quarkus con soporte nativo para JWT.
 
**Para qué sirve:** proteger endpoints y controlar acceso por roles.
 
```xml
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-smallrye-jwt</artifactId>
</dependency>
```
 
**Configuración:**
```properties
mp.jwt.verify.publickey.location=publicKey.pem
mp.jwt.verify.issuer=https://mi-app.com
quarkus.http.auth.permission.authenticated.paths=/api/*
quarkus.http.auth.permission.authenticated.policy=authenticated
```
 
**Proteger endpoints por rol:**
```java
@Path("/admin")
@Authenticated  // cualquier usuario autenticado
public class AdminResource {
 
    @GET
    @RolesAllowed("ADMIN")  // solo rol ADMIN
    public List<UserDto> findAll() { ... }
 
    @GET
    @Path("/me")
    @RolesAllowed({"ADMIN", "USER"})  // varios roles
    public UserDto getMe() { ... }
 
    @GET
    @Path("/public")
    @PermitAll  // sin autenticación
    public String health() { return "ok"; }
}
```
 
**Obtener el usuario autenticado:**
```java
@Inject
JsonWebToken jwt;
 
public String getCurrentUser() {
    return jwt.getName();  // subject del token
}
 
public Set<String> getRoles() {
    return jwt.getGroups();
}
```
 
---
 
## 13. Testing con QuarkusTest
 
**Qué es:** framework de testing integrado en Quarkus que levanta la aplicación real en modo test.
 
**Para qué sirve:** hacer tests de integración sobre los endpoints HTTP sin mocks del servidor.
 
```xml
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-junit5</artifactId>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>io.rest-assured</groupId>
    <artifactId>rest-assured</artifactId>
    <scope>test</scope>
</dependency>
```
 
**Test de endpoint:**
```java
@QuarkusTest
class UserResourceTest {
 
    @Test
    void findAll_returnsOk() {
        given()
            .when().get("/users")
            .then()
                .statusCode(200)
                .body("$.size()", greaterThan(0));
    }
 
    @Test
    void findById_returnsUser() {
        given()
            .when().get("/users/1")
            .then()
                .statusCode(200)
                .body("name", equalTo("Cristian"));
    }
 
    @Test
    void save_returnsCreated() {
        UserDto dto = new UserDto("Nuevo User", "nuevo@gmail.com");
 
        given()
            .contentType(ContentType.JSON)
            .body(dto)
            .when().post("/users")
            .then()
                .statusCode(201)
                .body("name", equalTo("Nuevo User"));
    }
 
    @Test
    void findById_notFound_returns404() {
        given()
            .when().get("/users/9999")
            .then()
                .statusCode(404);
    }
}
```
 
**Mock de beans con `@InjectMock`:**
```java
@QuarkusTest
class UserResourceTest {
 
    @InjectMock
    UserService userService;
 
    @Test
    void findAll_withMock() {
        Mockito.when(userService.findAll())
               .thenReturn(List.of(new UserDto("Mock User")));
 
        given()
            .when().get("/users")
            .then()
                .statusCode(200)
                .body("[0].name", equalTo("Mock User"));
    }
}
```
 
---
 
## 14. Native Build
 
**Qué es:** compilación de la aplicación Java a un binario nativo usando GraalVM (sin JVM en runtime).

 Cuando se dice **“compilar a binario nativo”** me refiero a algo muy simple: en vez de generar un **JAR** que necesita la **JVM** para ejecutarse, tu aplicación se transforma directamente en un **programa ejecutable del sistema operativo** (un archivo `.exe` en Windows, o un binario en Linux/Mac).
 
**Para qué sirve:** arranque en milisegundos y consumo de RAM mínimo. Ideal para serverless, containers, y microservicios cloud.
 
```
JVM tradicional:         Quarkus Native:
JAR → JVM → App         Binario → App directamente
Arranque: ~3 seg         Arranque: ~0.05 seg
RAM: ~200 MB             RAM: ~15 MB
```
 
**Requisitos:**
- GraalVM instalado, o
- Docker (para build sin instalar GraalVM localmente)
**Comandos:**
```bash
# Build nativo con GraalVM instalado
./mvnw package -Pnative
 
# Build nativo con Docker (sin instalar GraalVM)
./mvnw package -Pnative -Dquarkus.native.container-build=true
 
# Ejecutar el binario
./target/my-app-1.0-runner
```
 
**Dockerfile para producción:**
```dockerfile
FROM quay.io/quarkus/quarkus-micro-image:2.0
WORKDIR /work/
COPY --chown=1001:root target/*-runner /work/application
RUN chmod 775 /work
EXPOSE 8080
USER 1001
CMD ["./application", "-Dquarkus.http.host=0.0.0.0"]
```
 
> Para la mayoría de proyectos de aprendizaje o empresas peruanas, el native build es opcional. Lo importante es conocer que existe y para qué sirve.
 
---
 
## 15. Reactividad con Mutiny
 
**Qué es:** librería de programación reactiva de Quarkus (equivalente a Project Reactor de Spring).
 
**Para qué sirve:** manejar operaciones asíncronas y no bloqueantes en Quarkus.
 
**Tipos principales:**
 
| Mutiny | Equivalente Reactor | Descripción |
|---|---|---|
| `Uni<T>` | `Mono<T>` | 0 o 1 elemento |
| `Multi<T>` | `Flux<T>` | 0 a N elementos |
 
```java
// Uni — resultado único
Uni<User> user = userRepository.findById(1L);
 
// Multi — lista
Multi<User> users = userRepository.streamAll();
```
 
**Operadores básicos:**
```java
// map — transformar
Uni<UserDto> dto = userRepository.findById(1L)
        .map(user -> mapper.toDto(user));
 
// flatMap — operación asíncrona encadenada
Uni<UserDto> result = userRepository.findById(1L)
        .flatMap(user -> roleService.getRoles(user.id)
                .map(roles -> mapper.toDto(user, roles)));
 
// onItem — equivalente a doOnNext (efecto secundario)
uni.onItem().invoke(item -> log.info("Recibí: {}", item));
 
// manejo de error
uni.onFailure().recoverWithItem(new User("default"));
uni.onFailure().recoverWithUni(e -> Mono.just(new User("fallback")));
```
 
**Endpoint reactivo:**
```java
@GET
@Path("/{id}")
public Uni<Response> findById(@PathParam("id") Long id) {
    return userRepository.findById(id)
            .map(user -> Response.ok(mapper.toDto(user)).build())
            .onItem().ifNull().continueWith(Response.status(404).build());
}
```
 
> Mutiny es más simple que Reactor a propósito — menos operadores, más legible. Si ya sabes Reactor, Mutiny se aprende en horas.
 
---
 
## 16. Dependencias principales
 
### pom.xml (Maven)
 
```xml
<properties>
    <quarkus.platform.version>3.8.0</quarkus.platform.version>
</properties>
 
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>io.quarkus.platform</groupId>
            <artifactId>quarkus-bom</artifactId>
            <version>${quarkus.platform.version}</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
 
<dependencies>
    <!-- REST -->
    <dependency>
        <groupId>io.quarkus</groupId>
        <artifactId>quarkus-rest-jackson</artifactId>
    </dependency>
 
    <!-- ORM — Panache + PostgreSQL -->
    <dependency>
        <groupId>io.quarkus</groupId>
        <artifactId>quarkus-hibernate-orm-panache</artifactId>
    </dependency>
    <dependency>
        <groupId>io.quarkus</groupId>
        <artifactId>quarkus-jdbc-postgresql</artifactId>
    </dependency>
 
    <!-- Validación -->
    <dependency>
        <groupId>io.quarkus</groupId>
        <artifactId>quarkus-hibernate-validator</artifactId>
    </dependency>
 
    <!-- REST Client -->
    <dependency>
        <groupId>io.quarkus</groupId>
        <artifactId>quarkus-rest-client-jackson</artifactId>
    </dependency>
 
    <!-- Seguridad JWT -->
    <dependency>
        <groupId>io.quarkus</groupId>
        <artifactId>quarkus-smallrye-jwt</artifactId>
    </dependency>
 
    <!-- Reactivo con Mutiny (opcional) -->
    <dependency>
        <groupId>io.quarkus</groupId>
        <artifactId>quarkus-hibernate-reactive-panache</artifactId>
    </dependency>
 
    <!-- Testing -->
    <dependency>
        <groupId>io.quarkus</groupId>
        <artifactId>quarkus-junit5</artifactId>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>io.rest-assured</groupId>
        <artifactId>rest-assured</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>
```
 
---
 
## Resumen visual del stack
 
```
                    ┌──────────────────────────────┐
                    │       Tu Aplicación           │
                    │  Resources (JAX-RS)           │
                    │  Services (@ApplicationScoped)│
                    │  Repositories (Panache)       │
                    └────────────┬─────────────────┘
                                 │
                    ┌────────────▼─────────────────┐
                    │          Quarkus              │
                    │  (Framework + CDI container)  │
                    └────────────┬─────────────────┘
                                 │
                    ┌────────────▼─────────────────┐
                    │    RESTEasy / Vert.x          │
                    │  (servidor HTTP no bloqueante)│
                    └────────────┬─────────────────┘
                                 │
                    ┌────────────▼─────────────────┐
                    │    Hibernate ORM / Panache    │
                    │  (acceso a base de datos)     │
                    └────────────┬─────────────────┘
                                 │
                    ┌────────────▼─────────────────┐
                    │       GraalVM (opcional)      │
                    │  Native binary — sin JVM      │
                    └──────────────────────────────┘
```
 
## Flujo de una petición en Quarkus
 
```
Cliente HTTP
    │
    ▼
@Path("/users")  ← UserResource (JAX-RS)
    │  @Inject
    ▼
UserService (@ApplicationScoped)
    │  @Inject
    ▼
UserRepository (PanacheRepository)
    │
    ▼
Base de datos (PostgreSQL)
```
