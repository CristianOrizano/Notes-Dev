# Kafka - Spring Boot

Kafka es una plataforma de mensajería distribuida que permite enviar, recibir, almacenar y procesar grandes cantidades de datos en tiempo real.

Es ideal para que múltiples sistemas se comuniquen entre sí de manera eficiente y confiable, incluso si están en diferentes lugares o tiempos.

 Algunos conceptos clave incluyen:

- **Topics**: Canales de comunicación donde se envían y reciben los mensajes 
- **Producers**: Aplicaciones que envían mensajes a un topic.
- **Consumers**: Aplicaciones que leen mensajes de un topic.
- **Partitions**: Divisiones de un topic para distribuir mensajes.
- **Offsets**: Identificadores únicos para los mensajes dentro de una partición.
- **Brokers**: Servidores que almacenan y distribuyen mensajes.
- **Clusters**: Grupo de brokers que trabajan juntos.

 Dependencia de Kafka

```java
<dependency>
    <groupId>org.springframework.kafka</groupId>
    <artifactId>spring-kafka</artifactId>
</dependency>
```
### Productor

- Esta configuración permite crear los topics en el servidor de Kafka al iniciar la aplicación.

```java
@Configuration
public class KafkaAdminConfig {
    @Autowired
    private KafkaProperties kafkaProperties;

    // Configuración de KafkaAdmin para crear topics
    @Bean
    public KafkaAdmin kafkaAdmin(){
        Map<String, Object> configs = new HashMap<>();
        configs.put(AdminClientConfig.BOOTSTRAP_SERVERS_CONFIG,kafkaProperties.getBootstrapServers());
        return new KafkaAdmin(configs);
    }

    // Definición de los topics que deben ser creados
    @Bean
    public KafkaAdmin.NewTopics topics(){
        return new KafkaAdmin.NewTopics(
                TopicBuilder.name("str-topic").partitions(2).replicas(1).build()
        );
    }
}
```
- Esta configuración permite preparar el productor de Kafka para enviar mensajes a los topics definidos.

```java
@Configuration
public class ProducerFactoryConfig {
    @Autowired
    private KafkaProperties kafkaProperties; 

    //componente que configura los productores de Kafka
    @Bean
    public ProducerFactory<String,String> producerFactory(){
        var configs = new HashMap<String,Object>();
        configs.put(AdminClientConfig.BOOTSTRAP_SERVERS_CONFIG,kafkaProperties.getBootstrapServers()); 
        configs.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
        configs.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG,StringSerializer.class);
        return new DefaultKafkaProducerFactory<>(configs);
    }

   // componente principal para enviar mensajes a un topic de Kafka
   // En este caso, se configuró para enviar mensajes de tipo String
    @Bean
    public KafkaTemplate<String,String> kafkaTemplate(){
        return new KafkaTemplate<>(producerFactory());
    }
}
```

### Consumer
-  Esta configuración se encarga de establecer los componentes necesarios para recibir y procesar mensajes de Kafka. Configura las propiedades del consumidor, como los deserializadores y los servidores de Kafka, y proporciona una fábrica de listeners para gestionar los mensajes entrantes.

```java
@Log4j2
@Configuration
public class KafkaConsumerConfig {
    @Autowired
    private KafkaProperties kafkaProperties;

    @Bean
    public ConsumerFactory<String,String> consumerFactory(){
        var configs = new HashMap<String,Object>();
        configs.put(AdminClientConfig.BOOTSTRAP_SERVERS_CONFIG,kafkaProperties.getBootstrapServers());
        configs.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        configs.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG,StringDeserializer.class);
        return new DefaultKafkaConsumerFactory<>(configs);
    }
    @Bean
    public ConcurrentKafkaListenerContainerFactory<String,String> validMessageContainerFactory(ConsumerFactory<String,String> consumerFactory){
        var factory = new ConcurrentKafkaListenerContainerFactory<String,String>();
        factory.setConsumerFactory(consumerFactory);
        return factory;
    }

}
```
-  Esta es el servicio que escuchara o recibira  el mensaje enviado al topic de kafka
```java
    @KafkaListener(topics = "str-topic", groupId = "test-group1")
    public void consumeMessage1(String message) {
        log.info("LISTENER1 ::: Recibiendo un mensaje {}",message);
    }
```

### Principio S.O.L.I.D

**1) Single Responsibility**

- se refiere a que cada clase debe tener una sola responsabilidad o propósito en el sistema.

**2) Open/Closed Principle** 

- No deberías modificar el código existente para agregar nueva funcionalidad.
Debes extender el comportamiento usando herencia, inyección de dependencias, o patrones como estrategia.

**3) Liskov Substitution**
 
- asegura que cualquier objeto de una subclase puede sustituir a un objeto de la clase base sin alterar el comportamiento del sistema

**4) Interface Segregation Principle**

- asegura de que las clases no sean obligadas a implementar interfaces que no usan.

**5)  Dependency Inversion**

-  las clases de alto nivel no deben depender de clases de bajo nivel, sino de abstracciones
 
