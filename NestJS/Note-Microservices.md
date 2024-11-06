
# Microservicios

Los **microservicios** son un estilo arquitectónico para el diseño de aplicaciones en el que una aplicación se descompone en un conjunto de servicios pequeños, autónomos y modulares. Cada microservicio se enfoca en una única responsabilidad o función de negocio y se comunica con otros servicios a través de interfaces bien definidas, generalmente mediante **APIs REST** o **mensajería asíncrona**.

### 1. **Descomposición en Servicios Independientes**

-   Cada microservicio está diseñado para realizar una tarea o conjunto de tareas relacionadas, como la gestión de usuarios, la facturación, el procesamiento de pagos, etc.
-   Los microservicios son **independientes**, lo que significa que pueden ser desplegados, escalados y gestionados por separado. Esto permite una mayor flexibilidad y agilidad.
### 2. **Comunicación entre Microservicios**

-   Los microservicios **no comparten base de datos**, en su lugar, cada uno tiene su propia base de datos, lo que garantiza un **acoplamiento débil**.
-   Se comunican entre sí mediante **APIs REST**, **gRPC**, **sockets** o sistemas de mensajería como **Kafka** o **RabbitMQ**.
-   **Sistemas distribuidos**: La comunicación entre servicios se lleva a cabo a través de la red, lo que puede implicar una latencia y la necesidad de manejar fallos en la red.
### 3. **Escalabilidad y Despliegue Independiente**

-   Dado que los microservicios son modulares, se pueden **escalar de manera independiente** según las necesidades. Por ejemplo, un microservicio que maneja pagos podría necesitar más recursos que el microservicio que gestiona los usuarios.
-   Cada microservicio se despliega de forma independiente, lo que mejora la capacidad de **actualización continua** y el **desarrollo ágil**.

### **Gateway**

El **API Gateway** es un patrón arquitectónico que actúa como el punto de entrada único para todas las solicitudes hacia los microservicios de un sistema. En lugar de que cada cliente (por ejemplo, una aplicación frontend o un microservicio) se comunique directamente con los microservicios individuales, el cliente interactúa con el **API Gateway**, que luego se encarga de enrutar, gestionar y posiblemente modificar esas solicitudes antes de que lleguen a los microservicios correspondientes.


-   **Ruteo de solicitudes**: El API Gateway recibe las solicitudes de los clientes y las enruta al microservicio adecuado. Por ejemplo, si un cliente solicita datos de un servicio de usuarios y otro de productos, el API Gateway se encarga de enviar esas solicitudes a los microservicios de usuarios y productos.
    
-   **Agregación de respuestas**: En algunos casos, un cliente puede necesitar datos de varios microservicios. El API Gateway puede hacer varias solicitudes a diferentes microservicios, recopilar las respuestas y devolverlas como una sola respuesta combinada al cliente. Esto es útil para evitar que el cliente tenga que hacer múltiples solicitudes y lidiar con la lógica de combinación de datos.
- **Autenticación y autorización**: El API Gateway puede encargarse de la validación de autenticación (como la verificación de un token JWT) y autorización antes de que las solicitudes lleguen a los microservicios. Esto centraliza la seguridad, lo que facilita su gestión en lugar de implementar seguridad en cada microservicio por separado.

### Comunicacion entre Microservicios

Cuando un microservicio A necesita comunicarse con un microservicio B, existen varios métodos que se suelen utilizar dependiendo de las necesidades específicas de la comunicación, como la sincronización, la velocidad, o la tolerancia a fallos. Aquí los métodos más comunes:



-   **Descripción:** Los microservicios se comunican mediante **HTTP** usando **APIs REST**. Este es el enfoque más común y sencillo, donde los microservicios A y B se exponen como servicios web con endpoints que pueden ser invocados a través de HTTP.

- **Descripción:** **gRPC** es un marco de trabajo de comunicación basado en HTTP/2, que permite una **comunicación de alto rendimiento** entre microservicios. Usa **Protocol Buffers** (protobuf) como formato de serialización, lo que lo hace más eficiente que las API REST tradicionales.
- **Descripción:** **Sistemas de mensajería** como **Kafka** o **RabbitMQ** permiten una **comunicación asíncrona** entre microservicios. En este caso, los microservicios envían y reciben mensajes a través de un **middleware de mensajería**. Este enfoque es adecuado para arquitecturas basadas en eventos y cuando se necesita desacoplar los microservicios.

**¿Cuál elegir?**

-   **APIs REST**: Adecuadas para solicitudes simples y comunicarse de forma directa entre microservicios. Ideal para sistemas que no requieren una comunicación constante o de alto rendimiento.
-   **gRPC**: Ideal cuando se necesita **alto rendimiento**, baja latencia y comunicación bidireccional rápida.
-   **Mensajería Asíncrona** (Kafka/RabbitMQ): Perfecto cuando los microservicios necesitan ser **desacoplados**, y para arquitecturas basadas en eventos donde los microservicios actúan de manera independiente.
-   **Sockets**: Útil cuando se requiere **comunicación en tiempo real** entre microservicios, como en sistemas de mensajería o notificaciones instantáneas.


### KAFKA 

