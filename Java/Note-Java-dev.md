# JAVA SPRING BOOT


### Instalar Java (JDK)

Spring Boot requiere Java 17 o superior (también funciona con Java 11).

- Descargá e instalá el **JDK (Java Development Kit)** desde:
  [https://adoptium.net](https://adoptium.net)

Luego verificá que esté correctamente instalado ejecutando estos comandos en tu terminal o consola:

 - java -version

 Instalar un IDE
 
 - IntelliJ IDEA (Community) 👉 https://www.jetbrains.com/idea/

### Dependencias Iniciales

**- Spring Web**
Para crear controladores REST y manejar solicitudes HTTP.

**- Spring Data JPA**
Para interactuar con la base de datos usando JPA/Hibernate.

**- MySQL Driver**
Para conectarte a una base de datos MySQL.

**- Spring Boot DevTools**
Para recargar automáticamente tu aplicación durante el desarrollo.

**- Lombok**
Para simplificar tu código eliminando getters, setters, y constructores repetitivos.

###  Swager IU

**Dependencia** 

```typescript
<!-- https://mvnrepository.com/artifact/org.springdoc/springdoc-openapi-starter-webmvc-ui -->
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.6.0</version>
</dependency>

```

No es estrictamente necesario hacer mucha configuración, ya que Springdoc OpenAPI trabaja con la configuración predeterminada, pero si quieres personalizarla, puedes crear una clase de configuración.

-  Opción 1: Configuración básica sin personalización
Solo con añadir la dependencia, deberías tener acceso a la documentación Swagger UI en http://localhost:8091/swagger-ui.html.

Springdoc OpenAPI detecta automáticamente tus controladores y expone la documentación sin necesidad de configuraciones adicionales.


- Opción 2: Configuración avanzada (opcional)
Si necesitas personalizar la documentación o agregar detalles adicionales como el título, descripción, o versión de tu API, puedes crear una clase de configuración. Aquí tienes un ejemplo de cómo hacerlo:
```typescript
@Configuration
public class OpenAPIConfig {
    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Gestion Ventas")
                        .version("v1")
                        .description("Backend gestion de ventas")
                        .contact(new Contact()
                                .name("Cristian Orizano")));
    }
}
```

### Validaciones

Para usar la validación en Java con Spring Boot, primero necesitas asegurarte de que la dependencia spring-boot-starter-validation esté incluida en tu archivo pom.xml. Ya lo hemos visto antes, pero es importante confirmar que esté presente:

```typescript
<dependency>
		<groupId>org.springframework.boot</groupId>
		<artifactId>spring-boot-starter-validation</artifactId>
	</dependency>

```
### Mapper DTO 

En Spring Boot puedes automatizar el proceso de mapeo entre DTOs y entidades utilizando bibliotecas como MapStruct o ModelMapper. Estas herramientas te permiten evitar la codificación manual del mapeo entre DTOs y entidades, mejorando la mantenibilidad y reduciendo la posibilidad de errores.

**MapStruct**
MapStruct es una herramienta de mapeo de objetos que te permite generar el código de mapeo en tiempo de compilación, lo que lo hace muy eficiente.

```typescript
<dependency>
    <groupId>org.mapstruct</groupId>
    <artifactId>mapstruct</artifactId>
    <version>1.5.2.Final</version>
</dependency>

<dependency>
    <groupId>org.mapstruct</groupId>
    <artifactId>mapstruct-processor</artifactId>
    <version>1.5.2.Final</version>
    <scope>provided</scope>
</dependency>
```

### Stream

**¿Qué es un Stream?**

El propósito del stream() es crear un flujo de datos, y toList() se usa al final del flujo para recolectar los resultados en una nueva lista.

A lo largo del flujo, puedes realizar operaciones intermedias sobre los elementos. Por ejemplo, cuando estás utilizando map(ciudadMapper::toCiudadDto), que es una operación intermedia. Esta operación toma cada Ciudad del flujo y la transforma en un CiudadDto. Esta operación no modifica el flujo original; en lugar de eso, produce un nuevo flujo con los elementos transformados. 

toList() crea una nueva colección (en este caso una lista) con los elementos transformados, que se devuelven como resultado del método.
```typescript
List<CiudadDto> ciudadDtos = ciudadRepository.findAll().stream() // 1. Crear el flujo
        .map(ciudadMapper::toCiudadDto) // 2. Transformar cada Ciudad en CiudadDto
        .toList(); // 3. Recolectar los resultados en una nueva lista
```

**Operaciones de Stream comunes**
- Intermedias (Transforman el flujo, no lo materializan):
  -   map: Convierte cada elemento en otro.
  -  filter: Excluye elementos que no cumplan una condición.
  - sorted: Ordena los elementos.
  - distinct: Elimina duplicados.

### Excepciones

- @ControllerAdvice

**Descripción:** Se utiliza para manejar excepciones en controladores de tipo @Controller o @RestController.
**Salida**: Si no especificas explícitamente el tipo de respuesta (como ResponseEntity), este devuelve una vista (template) para aplicaciones web basadas en servidor.
**Uso principal:** Ideal para aplicaciones que mezclan controladores de tipo @Controller (que renderizan vistas HTML) y @RestController (que devuelven JSON).


- @RestControllerAdvice

**Descripción:** Es una especialización de @ControllerAdvice que automáticamente aplica @ResponseBody a los métodos del controlador de excepciones.
**Salida:** Siempre devuelve el resultado en formato JSON o XML, según la configuración de la aplicación o el encabezado Accept de la solicitud.
**Uso principal**: Ideal para aplicaciones RESTful donde las respuestas son siempre JSON.


 - **Excepciones Personalizadas (como ResourceNotFoundException)**
 
**Definidas por ti:** Estas no existen en el framework o lenguaje. Las defines para capturar situaciones específicas que solo tu aplicación puede reconocer, como "Recurso no encontrado".
**Control explícito:** Tú decides cuándo lanzarla en tu código y cómo manejarla globalmente.

```typescript
@ResponseStatus(HttpStatus.NOT_FOUND) // Marca la excepción con un código de respuesta predeterminado
public class ResourceNotFoundException extends RuntimeException{
    public ResourceNotFoundException(String message) {
        super(message);
    }
}
```


**Ejemplo:**

**1)  Validación con @Valid:**

Cuando un controlador recibe una solicitud y tiene un parámetro anotado con @Valid, Spring valida automáticamente los datos usando las anotaciones de Bean Validation (@NotBlank, @Min, etc.).
Si los datos no cumplen los criterios de validación, Spring lanza una excepción específica: MethodArgumentNotValidException.


**2) Interceptar la excepción con @RestControllerAdvice:**

La anotación @RestControllerAdvice permite manejar de manera centralizada excepciones lanzadas por los controladores REST.
Cuando ocurre una excepción, Spring busca un método en una clase anotada con @RestControllerAdvice que esté marcado con @ExceptionHandler y que coincida con el tipo de excepción lanzada (en este caso, MethodArgumentNotValidException).

**3) Personalizar la respuesta:**

En el método anotado con @ExceptionHandler, puedes construir y devolver una respuesta personalizada en lugar de permitir que Spring devuelva la respuesta predeterminada.
Esto te permite formatear la salida en JSON, agregar mensajes claros y estructurados, y devolver un código de estado HTTP adecuado, como 400 Bad Request.

### Inyeccion Dependencias 

 **FINAL**

Cuando una variable se declara como final, significa que solo puede ser asignada una vez, ya sea en el momento de su declaración o en el constructor. Es decir, el valor de esa variable no se puede cambiar una vez que ha sido asignado. 

Inmutabilidad: Una vez que se ha inyectado la dependencia en el constructor, no se puede cambiar la referencia a ciudadMapper ni a ciudadRepository. Esto ayuda a garantizar que estos objetos sean inmutables, lo que puede reducir errores y mejorar la claridad del código.

Facilita el uso con inyección de dependencias: En el contexto de Spring, el uso de final en las dependencias inyectadas ayuda a que las referencias a esos objetos sean constantes y seguras después de que se haya completado la inyección. Esto

```typescript
private final CiudadMapper ciudadMapper; // Solo se puede asignar una vez.
private final CiudadRepository ciudadRepository; // Solo se puede asignar una vez.


```
 **RequiredArgsConstructor** 

Esta anotación genera un constructor que toma como parámetros todas las variables finales o aquellas marcadas como @NonNull en la clase. Esto es útil para clases que tienen dependencias que deben inyectarse en el constructor, especialmente en el contexto de inyección de dependencias (por ejemplo, en Spring).

 **Inyección de dependencias moderna (actual):**
 
Uso del constructor: Es la forma recomendada, y Spring maneja la inyección automáticamente al usar el constructor.
Sin necesidad de @Autowired: Si usas Spring 4.3 o versiones posteriores, puedes inyectar dependencias a través del constructor sin necesidad de @Autowired, ya que Spring lo hace implícitamente.

Ventaja: Garantiza la inmutabilidad (usando final en los campos) y asegura que todas las dependencias se pasen al crear el objeto, lo que hace más fácil el testeo unitario.

```typescript
@Service
public class CiudadServiceImpl implements ICiudadService {

    private final CiudadMapper ciudadMapper;
    private final CiudadRepository ciudadRepository;

    // Constructor para la inyección
    public CiudadServiceImpl(CiudadMapper ciudadMapper, CiudadRepository ciudadRepository) {
        this.ciudadMapper = ciudadMapper;
        this.ciudadRepository = ciudadRepository;
    }
}
```
 **Inyección de dependencias antigua:**

Uso de @Autowired: En versiones anteriores de Spring, la inyección de dependencias se hacía a través de la anotación @Autowired, ya sea en el constructor o en los campos.

Inyección en los campos: Puedes inyectar las dependencias directamente en los campos con @Autowired, pero no es recomendado por cuestiones de testeo y mantenimiento.

```typescript
@Service
public class CiudadServiceImpl implements ICiudadService {

    @Autowired  // Inyección en los campos
    private CiudadMapper ciudadMapper;

    @Autowired  // Inyección en los campos
    private CiudadRepository ciudadRepository;
}
```

### CascadeType.ALL en Spring (JPA/Hibernate)

En Spring (con JPA/Hibernate), el atributo `cascade = CascadeType.ALL` en una relación indica que todas las operaciones de persistencia que se realicen en la **entidad principal** se propagarán automáticamente a las **entidades relacionadas**. Esto incluye los siguientes tipos de operaciones:

 **Tipos de operaciones de Cascade**
1. **`PERSIST`**  
   Cuando la entidad principal se guarda en la base de datos (persistencia), también se guardan automáticamente las entidades relacionadas.

2. **`MERGE`**  
   Si la entidad principal se actualiza, las entidades relacionadas también se actualizan automáticamente.

3. **`REMOVE`**  
   Cuando la entidad principal se elimina, las entidades relacionadas también se eliminan.

4. **`REFRESH`**  
   Si se actualiza la entidad principal desde la base de datos, las entidades relacionadas también se sincronizan con la base de datos.

5. **`DETACH`**  
   Si la entidad principal se desvincula del contexto de persistencia (`EntityManager`), las entidades relacionadas también se desvinculan.

6. **`ALL`**  
   Representa la combinación de todas las operaciones anteriores. Usar `CascadeType.ALL` equivale a aplicar todas las opciones mencionadas.


###  Sucurity JWT  

```typescript
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>

<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-api</artifactId>
    <version>0.11.5</version>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-impl</artifactId>
    <version>0.11.5</version>
    <scope>runtime</scope>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-jackson</artifactId>
    <version>0.11.5</version>
    <scope>runtime</scope>
</dependency>
```


 **Las dependencias de JWT (jjwt-api, jjwt-impl, jjwt-jackson) se encargan de:**
 
Generar los tokens (al momento de autenticar).
Validar tokens (para asegurarte de que son válidos y no han expirado).

 **Spring Security, por su parte, permite integrar esos tokens en el flujo de seguridad:**

-  Proteger rutas: Configuras qué endpoints requieren autenticación.
- Filtros: Agregas un filtro para validar los JWT (como el filtro JwtRequestFilter).
- Contexto de autenticación: Asocia los datos del token JWT (como el username) con el contexto de Spring Security para manejar permisos y roles.

---
#### 1. **Implementación de `UserDetailsService`**

- **Objetivo**: Cargar los datos del usuario autenticado desde una fuente de datos (por ejemplo, base de datos) y proporcionar esa información a la aplicación para manejar la autenticación.
- **Función**: Su propósito es cargar la información del usuario durante el proceso de autenticación, proporcionando una representación del usuario que incluye detalles como el nombre de usuario, la contraseña y los roles/autorizaciones que tiene..

#### 2. **`JwtAuthenticationEntryPoint`**
- **Objetivo**: Controlar los errores cuando un usuario no está autorizado o intenta acceder a recursos protegidos sin un token válido.
- **Función**: En caso de que el usuario no esté autenticado o el token sea inválido, se devuelve una respuesta de error adecuada (generalmente HTTP 401).

#### 3. **`JwtAuthenticationFilter`**
- **Objetivo**: Interceptar todas las solicitudes entrantes para verificar si el JWT proporcionado es válido.
- **Función**: Este filtro se encarga de extraer el token del encabezado `Authorization`, validar su firma y asegurarse de que el usuario esté autenticado.

#### 4. **`JwtTokenProvider`**
- **Objetivo**: Proporcionar los métodos necesarios para generar el token JWT y verificar su validez.
- **Función**: Esta clase gestiona la creación del token (por ejemplo, incluyendo la firma y fecha de expiración) y la validación de su integridad, asegurando que el token sea legítimo y no haya sido manipulado.

#### 5. **`SecurityConfig`**
- **Objetivo**: Gestionar y controlar el proceso de autenticación y autorización en toda la aplicación.
- **Función**: Define cómo se deben proteger las rutas de la aplicación, qué filtros deben aplicarse, y las configuraciones específicas relacionadas con la seguridad, como la habilitación de CSRF, los encabezados CORS y el uso de JWT en la autenticación.

---



# Testing con JUnit 5 y Mockito

### 📌 ¿Qué es JUnit 5?

**JUnit 5** es el framework moderno más utilizado para realizar **pruebas unitarias en Java**. Fue diseñado para reemplazar JUnit 4 con una arquitectura más modular, flexible y potente.

JUnit 5 está compuesto por tres subproyectos principales:

- **JUnit Platform**: Es la base sobre la que se ejecutan los tests. Permite integrar IDEs, herramientas de build (como Maven o Gradle) y otros frameworks.
- **JUnit Jupiter**: Contiene la API y las anotaciones para escribir y ejecutar pruebas (como `@Test`, `@BeforeEach`, etc.). Es la parte que realmente usas al escribir tests.
- **JUnit Vintage**: Permite ejecutar pruebas escritas con JUnit 3 o 4 dentro de JUnit 5, útil para mantener compatibilidad con código antiguo.

🎯 **Propósito de JUnit 5**:  
Permitir escribir, organizar y ejecutar pruebas unitarias de forma clara, moderna y extensible en proyectos Java.

✅ Facilita:
- Detectar errores de forma temprana.
- Refactorizar con seguridad.
- Automatizar validaciones en el ciclo de desarrollo.
- 
### 🧩 Anotaciones básicas de JUnit 5

- **@Test**: Marca un método como un caso de prueba. Es la anotación principal en una prueba unitaria.

- **@BeforeEach**: Se ejecuta antes de cada test. Se usa para preparar el entorno o inicializar objetos necesarios.

- **@AfterEach**: Se ejecuta después de cada test. Útil para limpiar recursos utilizados durante la prueba.

- **@BeforeAll**: Se ejecuta una sola vez antes de todos los métodos de prueba de la clase. El método debe ser estático.

- **@AfterAll**: Se ejecuta una sola vez después de todos los métodos de prueba de la clase. También debe ser estático.

- **@DisplayName**: Permite asignar un nombre descriptivo y legible a una prueba, útil para reportes o en el IDE.

- **@Disabled**: Desactiva temporalmente una prueba o clase de prueba, evitando su ejecución.

### ✅ Métodos de aserción en JUnit 5

Los métodos de aserción se utilizan para verificar que los resultados obtenidos sean los esperados durante una prueba unitaria.

- **assertEquals(expected, actual)**: Verifica que dos valores sean iguales.

- **assertNotEquals(expected, actual)**: Verifica que dos valores no sean iguales.

- **assertTrue(condition)**: Verifica que una condición sea verdadera.

- **assertFalse(condition)**: Verifica que una condición sea falsa.

- **assertNull(object)**: Verifica que un objeto sea `null`.

- **assertNotNull(object)**: Verifica que un objeto no sea `null`.


### ✅ Mockito - Mockeo de dependencias

#### 📌 ¿Qué es un mock?

Un **mock** es un objeto simulado que imita el comportamiento de una clase real. Se usa en pruebas unitarias para **aislar la lógica de la clase que se está probando**, evitando que interactúe con dependencias reales como bases de datos, servicios externos o APIs.

#### 🎯 ¿Por qué se usa?

- Para **controlar el comportamiento** de dependencias externas.
- Para **evitar efectos secundarios**, como escribir en bases de datos o hacer llamadas HTTP reales.
- Para **verificar interacciones** entre clases.
- Para hacer pruebas **más rápidas y confiables**, sin depender del entorno.

---

#### 🧩 Anotaciones principales de Mockito

- **@Mock**: Crea un objeto simulado (mock) de una clase o interfaz.

- **@InjectMocks**: Inyecta los objetos simulados (marcados con `@Mock`) en la clase que se desea probar.

- **@Spy**: Crea un objeto parcialmente simulado, que ejecuta métodos reales salvo que se especifiquen comportamientos.

---

#### ⚙️ Comportamiento simulado

- **when(...).thenReturn(...)**: Define qué debe devolver un método del mock cuando es llamado con ciertos parámetros.

- **when(...).thenThrow(...)**: Indica que se debe lanzar una excepción cuando se llame al método con ciertos parámetros.

---

#### 🔍 Verificación de comportamiento

- **verify(...)**: Verifica que un método del mock haya sido invocado.

- **verify(..., times(n))**: Verifica que el método haya sido invocado exactamente n veces.

- **verify(..., never())**: Verifica que el método **no haya sido invocado**.



### **¿Qué es una prueba unitaria?**

Una **prueba unitaria** (unit test) es una prueba que valida el **comportamiento de una unidad individual de código**, como un método o función, de forma **aislada** del resto del sistema.

#### **Beneficios del Testing (pruebas unitarias)**

1.  ✅ **Detección temprana de errores**  
    Puedes detectar bugs desde el principio, antes de que afecten a producción.
    
2.  🛠️ **Facilita el refactor**  
    Puedes cambiar la implementación interna de una clase y verificar que sigue funcionando, si los tests pasan.
    
3.  📈 **Mejora la calidad del código**  
    Te obliga a pensar en cómo dividir la lógica y mantener las funciones simples y testeables.
    
4.  🚦 **Sirve como documentación viva**  
    Un test bien escrito dice claramente qué se espera de una función o clase.
    
5.  🔄 **Permite regresión automática**  
    Cada vez que haces un cambio, ejecutas los tests para asegurarte de no romper lo anterior.

#### **Estructura de una prueba unitaria: AAA**

Esto se conoce como el patrón **AAA**:

#### 1. **Arrange (Preparar)**
Configuras el entorno del test. Creas los objetos necesarios, defines los valores de entrada y, si usas mocks, configuras su comportamiento.

`int  precio  =  100; int  descuento  =  10;` 

#### 2. **Act (Actuar)**

Llamas al método o función que estás testeando.

`int  resultado  = calcularDescuento(precio, descuento);` 

#### 3. **Assert (Afirmar)**

Verificas que el resultado sea el esperado.

`assertEquals(90, resultado);` 


### **¿Qué es una prueba de integración?**

Una **prueba de integración** verifica cómo interactúan varios componentes del sistema entre sí, como servicios, controladores, repositorios y configuración de Spring. A diferencia de las pruebas unitarias, aquí **no se aísla la lógica**, sino que se prueba el flujo real completo o parcialmente.

---

#### 🎯 ¿Por qué son importantes?

- Verifican que **la configuración de Spring esté correcta**.
- Aseguran que los **beans se inyecten adecuadamente**.
- Validan la **integración real con la base de datos, servicios REST o seguridad**.
- Detectan errores que no aparecen en pruebas unitarias, como problemas de contexto o wiring.

---

#### 🧩 Anotaciones clave en pruebas de integración

- **@SpringBootTest**: Carga todo el contexto de Spring. Se usa para probar la aplicación completa o flujos complejos de varios componentes.

- **@WebMvcTest**: Carga solo los componentes relacionados con la capa web (controladores, filtros). Ideal para probar endpoints REST sin cargar la lógica de negocio.

- **@DataJpaTest**: Se usa para probar la capa de repositorios. Carga únicamente los beans relacionados a JPA, usando por defecto una base de datos en memoria (como H2).

- **@AutoConfigureMockMvc**: Permite inyectar y usar `MockMvc` para simular peticiones HTTP.

- **@MockBean**: Crea e inyecta un mock dentro del contexto de Spring, reemplazando el bean real por uno simulado.

---

#### 🛠 Herramientas comunes

- **MockMvc**: Permite simular peticiones HTTP a controladores sin levantar un servidor real.
- **ObjectMapper**: Se usa para convertir objetos a JSON y viceversa.
- **H2** (u otra BD en memoria): Se usa para pruebas reales de base de datos sin tocar datos de producción.











