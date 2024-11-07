
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
Kafka es una plataforma de mensajería basada en un **sistema de colas de eventos**, lo que significa que los servicios pueden **enviar y recibir mensajes de manera asíncrona**. Esto es fundamental en una arquitectura de eventos, donde los servicios reaccionan a eventos que ocurren en tiempo real, sin necesidad de depender de un flujo secuencial o síncrono.

En una arquitectura tradicional, los servicios están fuertemente **acoplados** y dependen de la ejecución secuencial. En Kafka, los productores (que emiten eventos) y los consumidores (que procesan los eventos) están **desacoplados**. Los productores no necesitan saber qué consumidores existen ni cómo se procesan los eventos. Esto permite **escalar** y **modificar** los servicios de forma independiente.

-   **Producer**: Envia mensajes a los **topics**.
-   **Consumer**: Se suscribe a los **topics** y recibe los mensajes.
-   **Topics**: Canales de comunicación donde se envían y reciben los mensajes (eventos).
-   **Broker**: Almacena y distribuye los mensajes entre productores y consumidores.
-   **Message Patterns**:
    -   **@MessagePattern**: Usado para recibir mensajes de manera sincrónica (petición-respuesta).
    -   **@EventPattern**: Usado para recibir eventos de manera asincrónica (publicar-suscribir).

#### Casos de uso de Kafka:

-   **Integración de sistemas**: Facilita la comunicación entre microservicios y otros sistemas, manteniendo un flujo de datos constante y confiable.
-   **Procesamiento de eventos**: Para aplicaciones que necesitan análisis en tiempo real de datos entrantes.
-   **ETL en tiempo real**: Kafka permite transformar y mover datos entre sistemas en tiempo real.
-   **Monitoreo y análisis de logs**: Recopilación y análisis de logs de servidores y aplicaciones.

#### Ventajas de Kafka:

-   **Escalabilidad horizontal**: Kafka se puede escalar fácilmente agregando más brokers.
-   **Baja latencia**: Es capaz de manejar grandes volúmenes de datos con muy baja latencia.
-   **Alta tolerancia a fallos**: Distribuye y replica datos, lo cual aumenta su resistencia frente a fallos.



**Arquitectura Impulsada por Eventos (EDA)**

La arquitectura impulsada por eventos es un patrón de diseño en el que los sistemas se construyen para responder a eventos que ocurren en tiempo real. En lugar de una estructura tradicional donde los servicios están fuertemente acoplados y siguen un flujo secuencial, EDA permite que los servicios se comuniquen de forma asíncrona a través de mensajes de eventos.

Kafka es ideal para EDA porque permite:

-   **Emitir eventos**: Un productor en Kafka genera eventos (por ejemplo, cuando ocurre una transacción en un sistema de pagos) y los envía a un _topic_ de Kafka.
-   **Suscribir servicios a eventos**: Los consumidores pueden suscribirse a los _topics_ y recibir los eventos en el momento en que se publican, permitiendo que los servicios interesados reaccionen de inmediato.
-   **Almacenamiento y reintento**: Kafka permite almacenar los eventos y, en caso de fallo, volver a procesarlos, lo que ayuda a gestionar la resiliencia y la recuperación ante errores.

**Observable**  y **Observer**

-   **Observable**: es el origen de los datos. Es un objeto que **emite valores** a lo largo del tiempo. Los valores pueden ser cualquier cosa: datos de una API, eventos de usuario, mensajes de estado, etc. El Observable define cómo y cuándo emitirá esos valores.
    
-   **Observer (Observador)**: es quien **se suscribe** al Observable para "escuchar" esos valores emitidos. Al suscribirse, el Observer puede procesar los valores que el Observable emite, manejar posibles errores, y saber cuándo el flujo de datos ha terminado.
    
    -   Cada vez que el Observable emite un valor, el Observer lo recibe en su método `next`.
    -   Si ocurre un error, el método `error` del Observer se ejecuta.
    -   Cuando el Observable termina de emitir, se llama al método `complete`.


**Kafka- NEST JS**


**`ClientsModule.register([...])`**:  
Esta configuración te permite crear un cliente Kafka que puedes inyectar en cualquier servicio o controlador de NestJS para enviar mensajes a Kafka, actuando como productor. Es útil cuando solo quieres que ciertos servicios interactúen con Kafka, sin hacer que todo el microservicio dependa directamente de Kafka.

Ejemplo: Dado que `shop` solo necesita enviar mensajes a Kafka, puedes utilizar la configuración de `ClientsModule.register`. Esto permite que el microservicio actúe exclusivamente como productor, enviando mensajes cuando sea necesario, sin establecer una conexión persistente de Kafka para toda la aplicación.

```typescript
	ClientsModule.register([
			{
				name: 'KAFKA_SERVICE', // Identificador del cliente Kafka
				transport: Transport.KAFKA,
				options: {
					client: {
						brokers: ['localhost:9092'], // Dirección de tu broker Kafka
					},
					consumer: {
						groupId: 'shop-consumer', // Grupo de consumidores
					},
				},
			},
		]),

```
**`app.connectMicroservice({...})` y `app.startAllMicroservices()`**:  
Este enfoque configura Kafka como transporte principal del microservicio. Esto es especialmente útil si quieres que todo el microservicio actúe como consumidor de Kafka, procesando mensajes que llegan a través de Kafka. También permite que el microservicio se registre en Kafka y comience a recibir mensajes de forma independiente de los controladores HTTP.

Ejemplo: Para `auth`, donde necesitas que el microservicio consuma mensajes de Kafka de manera persistente, es recomendable utilizar `connectMicroservice` y `startAllMicroservices`. Esta configuración convierte `auth` en un microservicio Kafka completo, escuchando de forma continua los mensajes que llegan al topic `categoria.demo`.
```typescript
const kafkaMicroservice = app.connectMicroservice<MicroserviceOptions>({
		transport: Transport.KAFKA,
		options: {
			client: {
				brokers: ['localhost:9092'], // Ajusta según tu configuración
			},
			consumer: {
				groupId: 'auth-consumer', // El grupo de consumidores que utilizará este microservicio
			},
		},
	});

	// Inicia todos los microservicios
	await app.startAllMicroservices();
```


#### **Paso 1: Productor Publica un Evento**

Un servicio productor genera un evento (mensaje) y lo envía a un **topic** específico en Kafka. Un **topic** es una categoría o canal al que los productores envían mensajes y a donde los consumidores se suscriben para recibir mensajes.

**Ejemplo de Productor:**

-   Un servicio `OrderService` emite un evento cuando se crea un nuevo pedido.

```typescript
@Get('order/create')
async createOrder() {
  const order = { id: 1, product: 'Laptop', quantity: 1 };

  // Publicar el evento en el topic 'order.created'
  this.clientKafka.emit('order.created', order);
  return { message: 'Order created', order };
}
```
#### **Paso 2: Kafka Recibe el Evento**

-   Kafka recibe el mensaje de un productor en el topic correspondiente (`order.created`).
-   Kafka lo almacena de manera distribuida, permitiendo que los consumidores que están suscritos a ese topic reciban el mensaje de manera **asíncrona**.

#### **Paso 3: Consumidor Recibe el Evento**

Un **consumidor** se suscribe al topic `order.created` para recibir los eventos cuando se publiquen en ese topic. Un consumidor puede estar interesado en procesar ese evento y realizar alguna acción en consecuencia (por ejemplo, enviar una notificación o actualizar un sistema de inventario).

**Ejemplo de Consumidor:**

-   Un servicio `InventoryService` escucha el evento `order.created` para actualizar el inventario.

```typescript

// Consumidor (InventoryService)
@EventPattern('order.created')
async handleOrderCreated(@Payload() message: any) {
  console.log('Nuevo pedido recibido:', message);
  
  // Lógica de negocio, por ejemplo, actualizar inventario
  const { id, product, quantity } = message;
  console.log(`Actualizando inventario de ${product} con cantidad ${quantity}.`);
}

```


