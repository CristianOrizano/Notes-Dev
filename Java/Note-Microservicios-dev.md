# MICROSERVICIOS - SPRING BOOT

### Comunicación entre microservicios 

 - **Feign Client**: Úsalo si ya estás en un ecosistema Spring Cloud o necesitas simplicidad para comunicaciones REST.

 - **WebClient:** Elige este si necesitas programación reactiva, alta concurrencia o un enfoque no bloqueante.

 Evita RestTemplate para proyectos nuevos. Aunque es más fácil de usar, no tendrá soporte a largo plazo.

 **Usar WebClient** 
 
1) instalar dependencia

```java
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-webflux</artifactId>
</dependency>
```

2) Añadir una configuracion

```java
@Configuration  
public class WebClientConfig {  
@Bean  
public WebClient.Builder webClientBuilder() {  
return WebClient.builder();  
 }  
}
```

3) Implementar en un servicio

```java
@Service
public class HabitacionService  implements IHabitacionService {
    private final WebClient webClient;

    public HabitacionService(WebClient.Builder webClientBuilder) {
        this.webClient = webClientBuilder.baseUrl("http://localhost:8092/api/habitacion").build();
    }

    @Override
    public List<HabitacionDto> findAll() {
        return webClient.get()
                .retrieve()
                .onStatus(status -> status.is4xxClientError(), response -> {
                    if (response.statusCode() == HttpStatus.NOT_FOUND) {
                        return Mono.error(new ResourceNotFoundException("No se encontraron habitaciones disponibles."));
                    }
                    return Mono.error(new ResponseStatusException(HttpStatus.BAD_REQUEST, "Error en la solicitud: " + response.statusCode()));
                })
                .bodyToFlux(HabitacionDto.class)
                .collectList()
                .block(); // Si es síncrono
    }

```

 **Usar Feign Client** 

1) instalar dependencia

```java
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-openfeign</artifactId>
</dependency>
```
2) Habilitar Feign en la aplicación: En la clase principal de la aplicación (usualmente la clase con la anotación @SpringBootApplication), agrega la anotación @EnableFeignClients para habilitar Feign Client en la aplicación.

```java
@SpringBootApplication
@EnableFeignClients
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}

```
3) Crear un Feign Client: Ahora, crea una interfaz Feign Client para interactuar con el servicio que deseas consumir (en este caso, el servicio que retorna la habitación por ID).

```java
@FeignClient(name = "habitacionClient", url = "http://localhost:8080")
public interface HabitacionClient {

    @GetMapping("/api/habitaciones/{id}")
    HabitacionDto getHabitacionById(@PathVariable("id") Long id);
}

```

### Servidor de Configuracion

Un Servidor de Configuración (o Config Server) es un componente clave en una arquitectura de microservicios que centraliza y administra las configuraciones de todos los microservicios de tu sistema. En lugar de que cada microservicio tenga su propia configuración de manera local, el Config Server permite:

- **Centralización:** Todas las configuraciones se almacenan en un lugar único y son accesibles para todos los servicios.

- **Versionamiento:** Si utilizas un repositorio como Git para almacenar las configuraciones, puedes versionarlas y rastrear los cambios.

- **Actualizaciones Dinámicas:** Los microservicios pueden obtener configuraciones actualizadas sin necesidad de reiniciarse (usando Spring Cloud Bus, por ejemplo).

- **Seguridad:** Las configuraciones sensibles, como claves API o contraseñas, se pueden cifrar.
---

**Config Server** 

1) Instalar Dependencia

Es necesaria cuando estás configurando un servidor de configuración centralizado en tu arquitectura de microservicios. Este servidor actúa como el repositorio central de configuraciones para todos tus microservicios, permitiéndote gestionar la configuración de forma centralizada.

```java
<dependency>
			<groupId>org.springframework.cloud</groupId>
			<artifactId>spring-cloud-config-server</artifactId>
</dependency>
```
2) habilitar la funcionalidad de servidor de configuración.
```java
@SpringBootApplication
@EnableConfigServer
public class ConfigServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(ConfigServerApplication.class, args);
    }
}
```

3) Propiedades
```java
server:
  port: 8888

spring:
  cloud:
    config:
      server:
        git:
          uri: https://github.com/CristianOrizano/config-repo  # tu repositorio
          default-label: main

```
---
**Configurar microservicios clientes**

1) Dependencias 

Esta es la dependencia principal que proporciona soporte para la integración con Spring Cloud Config. Permite que el microservicio obtenga su configuración centralizada desde un servidor de configuración, como el servidor de configuración basado en Git o en un repositorio local.

```java
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-config</artifactId>
</dependency>

```
se utiliza para habilitar la carga temprana de la configuración. Con spring-cloud-starter-bootstrap, Spring Boot cargará los archivos de configuración que provienen de Spring Cloud Config antes de iniciar la aplicación, lo que permite que todas las configuraciones necesarias estén disponibles en la fase de inicialización.

```java
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-bootstrap</artifactId>
</dependency>

```
2) Propiedades de Microservicios

```java
spring:
  application:
    name: hoteles-service
  cloud:
    config:
      enabled: true #Habilita la integración con Spring Cloud Config
      uri: http://localhost:8888
```
### Eureka 

Eureka es un servicio de descubrimiento de Spring Cloud que permite a los microservicios registrarse y encontrarse dinámicamente entre sí, sin necesidad de configuraciones fijas de direcciones IP o puertos.

 **Servidor Eureka**

1) Dependencia

```java
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-eureka-server</artifactId>
</dependency>
```

2) Habilita el servidor Eureka

```java
@SpringBootApplication
@EnableEurekaServer
public class EurekaServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(EurekaServerApplication.class, args);
    }
}
```
3) Configuración application.yml

```java
server:
  port: 8761

eureka:
  client:
    register-with-eureka: false
    fetch-registry: false
    service-url:
      default-zone: http://${eureka.instance.hostname}:${server.port}/eureka/

spring:
  application:
    name: eureka-server

```
**Cliente Eureka**

Cada microservicio actúa como un cliente de Eureka. Este cliente Se registra en el servidor.

1) Agrega la dependencia para el cliente Eureka:

```java
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
</dependency>

```

2) Habilita el cliente Eureka

```java
@SpringBootApplication
@EnableDiscoveryClient
public class HotelServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(HotelServiceApplication.class, args);
    }
}

```

3) Configuración bootstrap.yml

```java
server:
  port: 8093

spring:
  application:
    name: reservas
eureka:
  instance:
    hostname: localhost
  client:
    fetch-registry: true  # El cliente descarga la lista de servicios registrados.
    register-with-eureka: true # El cliente se registra como un servicio en el servidor de Eureka.
    
    service-url:
      defaultZone: http://localhost:8761/eureka/

```

### Multiples Instancias 

Las múltiples instancias en Eureka son una práctica común en arquitecturas distribuidas y microservicios. Su propósito principal es garantizar escalabilidad, alta disponibilidad y tolerancia a fallos. Aquí tienes un desglose de sus beneficios y utilidad:


**. Escalabilidad**
Si un microservicio tiene múltiples instancias registradas en Eureka, estas pueden distribuir la carga de trabajo.
Eureka actúa como un Service Discovery, permitiendo a otros servicios encontrar todas las instancias disponibles.

**. Alta disponibilidad**
Con múltiples instancias, si una de ellas falla, las demás seguirán funcionando.
Los servicios que dependen de este microservicio pueden redirigir automáticamente las solicitudes a las instancias que aún están activas.

Ejemplo:

Si un servicio hoteles tiene 3 instancias (A, B, y C), y la instancia A falla, las solicitudes se redirigen automáticamente a B y C.


**. Reducción de tiempo de inactividad**
Cuando un microservicio está siendo actualizado o se reinicia, las otras instancias pueden seguir atendiendo las solicitudes, reduciendo el impacto en los usuarios finales.

```java
Ejemplo


- Por defecto se asignara un puerto aleatorio

server:
  port: 0

- identificador unico para cada instancia 

eureka:
  instance:
    instance-id: ${spring.application.name}:${random.value}

```

### Gateway

Un **Gateway** en **Spring Boot** es un componente que actúa como una puerta de entrada para todas las solicitudes hacia los microservicios en una arquitectura de microservicios.

1) Agrega la dependencia para el Gateway

```java
<dependency>  
  <groupId>org.springframework.cloud</groupId>  
  <artifactId>spring-cloud-starter-gateway</artifactId>  
</dependency>
```
2) Registrar en el eureka
```java
<dependency>  
  <groupId>org.springframework.cloud</groupId>  
  <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>  
</dependency>
```

3) Configurar Propiedades
```java
server:
  port: 8080

spring:
  application:
    name: gateway
  cloud:
    gateway:
      discovery:
        locator:
          enabled: true  
      routes:
        # Ruta para el microservicio HOTELES
        - id: hotel-service
          uri: lb://HOTELES
          predicates:
            - Path=/api/habitacion/**
        - id: auth-service
          uri: lb://AUTH
          predicates:
            - Path=/api/usuario/**,/api/login/**
eureka:
  client:
    register-with-eureka: true
    fetch-registry: true
    service-url:
      defaultZone: http://localhost:8761/eureka

```

**`enabled: true`**: Activa el descubrimiento de servicios en Spring Cloud Gateway.

**Automáticamente, el Gateway**:

-   **Descubre los microservicios** registrados en el servidor de descubrimiento (por ejemplo, Eureka).
-   **Enruta las solicitudes** a esos microservicios basándose en el nombre del servicio (usando la notación `lb://<service-name>` para balanceo de carga). No necesitas especificar manualmente las rutas para cada microservicio.

**Ejemplo de uso:**

Supongamos que tienes un microservicio llamado `HOTELES` registrado en Eureka. Con la configuración activada, podrías hacer una solicitud como:

` http://localhost:8080/HOTELES/api/habitacion/2`

```java
gateway:
  discovery:
    locator:
      enabled: true
```
### Spring Actuator

 **¿Qué es Spring Boot Actuator?**

**Spring Boot Actuator** es un módulo de Spring Boot que proporciona funcionalidades de monitoreo y gestión para aplicaciones basadas en Spring. Permite a los desarrolladores y administradores supervisar el estado, la salud y el comportamiento de una aplicación en tiempo real. Ofrece una variedad de endpoints HTTP que exponen información sobre la aplicación, como métricas, estado de los componentes, configuraciones, entre otros.


- `/actuator/health`    | Muestra el estado de salud de la aplicación y sus componentes.       
- `/actuator/info`      | Expone información personalizada sobre la aplicación. 
- `/actuator/metrics`   | Proporciona métricas relacionadas con la aplicación. 
- `/actuator/env`       | Muestra las propiedades de configuración actuales.  
- `/actuator/beans`     | Lista todos los beans cargados en el contexto de Spring.     
- `/actuator/loggers`   | Permite ver y cambiar niveles de logs en tiempo de ejecución.

1) Agregar Dependencia
```java
<dependency>  
  <groupId>org.springframework.boot</groupId>  
  <artifactId>spring-boot-starter-actuator</artifactId>  
</dependency>
```
2) Configurar `application.properties` o `application.yml`

Spring Actuator expone varios endpoints que puedes habilitar o deshabilitar según tu necesidad.
```java
management:
  endpoints:
    web:
      exposure:
        include: "*"
  health:
    circuitbreakers:
      enabled: true
  endpoint:
    health:
      show-details: always

```

### Circuit Breaker
El **Circuit Breaker** (o "interruptor de circuito") es un patrón de diseño utilizado en sistemas distribuidos para mejorar la resistencia y estabilidad de las aplicaciones. Su propósito es evitar que fallos en un servicio propaguen problemas a otros servicios que dependen de él. Funciona de manera similar a un interruptor eléctrico, interrumpiendo temporalmente las llamadas a un servicio cuando detecta que este está fallando.

El Circuit Breaker opera en tres estados principales:

1.  **Cerrado (Closed)**:
    
    -   El sistema funciona normalmente, y las solicitudes pasan al servicio externo.
    -   Si las llamadas empiezan a fallar por encima de un umbral configurado, el Circuit Breaker cambia al estado **Abierto**.
2.  **Abierto (Open)**:
    
    -   Todas las solicitudes al servicio fallido son bloqueadas inmediatamente (sin realizar la llamada real).
    -   Este estado evita sobrecargar al servicio con más solicitudes mientras está caído.
    -   Las solicitudes fallan rápidamente con un mensaje de error predefinido.
3.  **Semiabierto (Half-Open)**:
    
    -   Después de un período de espera (timeout), el Circuit Breaker permite un número limitado de solicitudes de prueba al servicio.
    -   Si estas solicitudes tienen éxito, el Circuit Breaker vuelve al estado **Cerrado**.
    -   Si las solicitudes fallan, el Circuit Breaker regresa al estado **Abierto**.

1) Agrega la dependencia para el Gateway

Se utiliza cuando estás trabajando en un **proyecto con Spring Cloud**, especialmente en aplicaciones **microservicios**.
```java

<dependency>
		<groupId>org.springframework.cloud</groupId>
		<artifactId>spring-cloud-starter-circuitbreaker-resilience4j</artifactId>
</dependency>

```
Es más directo y específico para **Spring Boot 3**, sin la necesidad de usar **Spring Cloud**.
```java
<dependency>
			<groupId>io.github.resilience4j</groupId>
			<artifactId>resilience4j-spring-boot3</artifactId>
			<version>2.2.0</version>
</dependency>

```
2) Propiedades
```java
resilience4j:
  circuitbreaker:
    configs:
      default:
        registerHealthIndicator: true  # Habilita un indicador de salud en /actuator/health para monitorear el estado del Circuit Breaker.
        slidingWindowType: TIME_BASED  # Define la ventana deslizante basada en el tiempo, en lugar de un número fijo de llamadas.
        slidingWindowSize: 10          # Tamaño de la ventana deslizante: si es TIME_BASED, mide 10 segundos; si es COUNT_BASED, rastrea 10 llamadas.
        permittedNumberOfCallsInHalfOpenState: 3  # Permite 3 llamadas en el estado Half-Open para verificar la recuperación del sistema.
        minimumNumberOfCalls: 5         # Requiere al menos 5 llamadas antes de evaluar la tasa de fallos y abrir el Circuit Breaker.
        waitDurationInOpenState: 10s    # Tiempo que permanece en estado Open antes de pasar a Half-Open para reintentar.
        failureRateThreshold: 50        # Umbral de fallos permitido (en porcentaje). Si más del 50% de las llamadas fallan, se abre el Circuit Breaker.
        eventConsumerBufferSize: 10     # Tamaño del buffer para almacenar eventos del Circuit Breaker (por ejemplo, aperturas y cierres).

```

### ZipKin
**Zipkin** es una herramienta de **tracing distribuido** que ayuda a monitoriar y depurar solicitudes en sistemas distribuidos, como arquitecturas de microservicios.

Zipkin se utiliza específicamente para rastrear el **flujo de solicitudes** a través de múltiples servicios.

Ayuda a identificar problemas de rendimiento y entender cómo interactúan diferentes servicios en una arquitectura compleja.

#### Funciones principales de una herramienta de tracing:

1.  **Seguimiento de solicitudes (Tracing):**  
    Permite rastrear cómo una solicitud fluye a través de múltiples servicios en un sistema distribuido.
    
2.  **Identificación de cuellos de botella:**  
    Detecta servicios que están causando demoras o fallos.
    
3.  **Visualización del flujo de datos:**  
    Muestra gráficos o diagramas del recorrido de las solicitudes.
    
4.  **Análisis de errores:**  
    Permite identificar en qué servicio o paso ocurrió un error.
    
5.  **Métricas y estadísticas:**  
    Proporciona datos sobre latencia, tiempos de respuesta, y frecuencias de errores.
```java
<!-- Micrometer Tracing con Brave -->
		<dependency>
			<groupId>io.micrometer</groupId>
			<artifactId>micrometer-tracing-bridge-brave</artifactId>
		</dependency>

<!-- Reportero de Zipkin para Brave -->
		<dependency>
			<groupId>io.zipkin.reporter2</groupId>
			<artifactId>zipkin-reporter-brave</artifactId>
		</dependency>

```

