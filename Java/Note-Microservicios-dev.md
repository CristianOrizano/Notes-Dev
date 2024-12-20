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

### Circuit Breaker




### ZipKin


