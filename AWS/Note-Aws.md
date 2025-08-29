# AWS (Amazon Web Services)

## VPC (Virtual Private Cloud)

**¿Qué es?**
Una **VPC es tu propia red privada dentro de AWS**.  
Es como tu “barrio exclusivo” 🏡 en la nube donde van a vivir tus recursos (EC2, RDS, Lambda, etc.), con reglas de **direcciones IP, seguridad y conectividad** que tú controlas.

**¿Para qué sirve?**
1.  **Aislar tus recursos**    
    -   Evita que tus servidores y bases de datos estén “sueltos” en Internet.      
    -   Cada proyecto/empresa suele tener su propia VPC.
       
2.  **Controlar quién entra y sale**    
    -   Con subnets públicas/privadas y security groups decides:        
        -   Qué recursos son accesibles desde Internet, accesible desde fuera (con la IP pública/DNS).
        -   Qué recursos quedan ocultos, solo accesible desde instancias en la misma VPC (ej: tu EC2).        
3.  **Definir red y seguridad**    
    -   Tú eliges el rango de IPs.        
    -   Creas subnets (públicas/privadas).        
    -   Conectas a Internet (Internet Gateway) o mantienes aislado.        
4.  **Conectar recursos entre sí**    
    -   Ejemplo típico: un **EC2 en subnet pública** accede a un **RDS en subnet privada**.

**“controlar quién entra y sale”**, significa:

-   **Entrar** → qué IPs/recursos pueden acceder a tu instancia/RDS/etc. 
-   **Salir** → hacia dónde puede conectarse tu instancia/RDS/etc.  
    Y esto está ligado a si el recurso está en **subnet pública o privada**.
    

## AWS CloudWatch

En **AWS**, **CloudWatch** es el servicio de **monitoreo y observabilidad**.  

👉 **CloudWatch te deja ver qué está pasando dentro de tus servicios y recursos en AWS.**

En **AWS CloudWatch** se guardan:

1.  **Logs de tu aplicación**
    -   Si en tu Lambda haces `console.log("Hola")`, eso se manda a CloudWatch Logs.        
    -   También `console.error`, `console.warn`, etc.
        
2.  **Logs del sistema**    
    -   Por ejemplo, si tu Lambda falla, el error y el _stack trace_ también aparecen en CloudWatch.       
3.  **Métricas**
    -   CloudWatch no es solo logs, también guarda **métricas** como:     
        -   Uso de CPU de una EC2         
        -   Memoria usada en un contenedor ECS            
        -   Número de invocaciones de una Lambda            
        -   Latencia de un API Gateway            
4.  **Alarmas**    
    -   Puedes configurar alarmas que te avisen (correo, SMS, Slack) si algo se dispara.        
    -   Ejemplo: si una Lambda falla más de 5 veces en 1 minuto → manda alerta.


## IAM

**¿Qué es IAM?**

Es el servicio de **gestión de usuarios, permisos y accesos** en AWS.  Con IAM decides **quién puede entrar** a tu cuenta de AWS y **qué puede hacer**.

**Puntos clave**

-   **Usuarios** → personas o aplicaciones que necesitan acceder (tú, tu equipo, un bot).    
-   **Grupos** → conjunto de usuarios con los mismos permisos.  
-   **Roles** → identidades temporales que asumen permisos (muy usado por servicios como EC2 o Lambda).    
-   **Policies (políticas)** → reglas que definen lo que **puedes o no puedes hacer** (ejemplo: leer un bucket S3, pero no borrarlo).

## EC2 (Elastic Compute Cloud)

**¿Qué es?**  
Es el servicio que te permite crear, tener máquinas virtuales (servidores) en la nube.
Piensa en él como si fuera una computadora que alquilas por horas o segundos, con el sistema operativo que quieras (Linux, Windows, etc.), y que puedes configurar con la potencia que necesites (CPU, RAM, disco).

**Para qué sirve:**
-  Desplegar y correr tus aplicaciones, APIs o sitios web.
-   Tener control total sobre el sistema operativo y software instalado.
-    Ejecutar cualquier servicio que necesite un servidor, con la flexibilidad de elegir recursos y sistema operativo.

**Características clave:**

-   **Tipos de instancia:** Diferentes tamaños (CPU, RAM) para ajustar costo y rendimiento.
-   **Sistema operativo:** Puedes elegir Linux, Windows, etc.
-   **Almacenamiento:** Usan discos virtuales llamados EBS (Elastic Block Store).
-   **Red:** Las instancias están dentro de una VPC (red virtual aislada).    
-   **Acceso:** Normalmente te conectas vía SSH (Linux) o RDP (Windows).    
-   **Elastic IP:** IP pública fija opcional para que tu servidor sea accesible desde internet.

**Ejecucion**
1. **Abra un cliente SSH**

2. **Localice el archivo de clave privada**  
   `electrodash-llave.pem`

3. **Asegure los permisos de la clave**  
   `chmod 400 "electrodash-llave.pem"`

4. **Conéctese por SSH**  
   `ssh -i "electrodash-llave.pem" ubuntu@ec2-50-16-116-87.compute-1.amazonaws.com`

5. **Instalar Java**  
   `sudo apt update && sudo apt install openjdk-17-jdk -y`

6. **Subir el JAR**  
   `scp -i "electrodash-llave.pem" target/app.jar ubuntu@<PUBLIC_IP>:/home/ubuntu/`

7. **Ejecutar la app**  
   `java -jar app.jar`

8. **Probar en navegador/Postman**  
   `http://<PUBLIC_IP>:8080`

9. **Correr en segundo plano**  
   `nohup java -jar gestionventas-0.0.1-SNAPSHOT.jar &`

## S3 (Simple Storage Service)

**¿Qué es?**  
Amazon S3 (Simple Storage Service) es un servicio de **almacenamiento en la nube** de AWS que te permite **guardar y recuperar cualquier cantidad de datos en cualquier momento y desde cualquier lugar**, a través de Internet.

 **¿Qué es exactamente S3?**

-   Es como un **"disco duro en la nube"**, pero muchísimo más grande, seguro y accesible globalmente.
-   No guarda archivos en carpetas físicas como en tu PC, sino en **buckets** (cubos), que son contenedores virtuales para tus datos.
-   Es **escalable**: puedes guardar desde un par de KB hasta petabytes sin preocuparte por límites de espacio.

 **¿Para qué sirve?**

-   **Almacenamiento de archivos estáticos**: imágenes, videos, documentos, backups, etc. 
-   **Hosting de sitios web estáticos**: HTML, CSS, JS.   
-   **Copia de seguridad y recuperación** (backup/restore).    
-   **Almacenamiento para big data y machine learning** (datasets). 
-   **Streaming de contenido** (ej. videos bajo demanda).

## RDS

**¿Qué es?**  
Amazon RDS es un servicio de **bases de datos relacionales en la nube** que AWS administra por ti.  
Puedes elegir entre motores como:

-   MySQL 
-   PostgreSQL    
-   MariaDB    
-   Oracle   
-   Microsoft SQL Server  
-   Aurora (motor propio de AWS)
- 
 **¿Para qué sirve?**
 
-   Guardar y consultar datos estructurados (tablas, relaciones, índices).
-   Tener una base de datos lista sin preocuparte de instalar, actualizar, hacer backup, o manejar hardware.  
-   Conectarte desde tu app backend igual que a una base de datos local.

## AWS Amplify

Es un servicio de AWS que te permite **desarrollar, hospedar y administrar aplicaciones web y móviles** de forma muy rápida.  
Es como un “todo en uno” para frontend + backend ligero.

**AWS Amplify** es un servicio de AWS que **facilita desarrollar, desplegar y escalar aplicaciones web y móviles fullstack**, enfocándose en proyectos donde **no quieres preocuparte por servidores tradicionales**.

**Qué hace**

1.  **Frontend Hosting**
    
    -   Publica tu Angular, React, Vue, Next.js, etc.
    -   Escalado automático, HTTPS, dominio personalizado.
        
2.  **Backend Serverless** 

Puedes **añadir un backend** con servicios serverless, **Servicios serverless** (como Cognito, S3, API Gateway, Lambda, DynamoDB) son **funcionalidades de backend que AWS te da listas para usar**, sin que tengas que configurar ni mantener servidores.
 
    
    -   Autenticación de usuarios (**Cognito**)      
    -   Almacenamiento de archivos (**S3**)       
    -   APIs REST o GraphQL (**API Gateway + Lambda / AppSync**)     
    -   Bases de datos NoSQL (**DynamoDB**)
        
3.  **Integración directa con frontend**
    
    -   Tu app Angular/React puede llamar a estos servicios usando el **SDK de Amplify**.  
    -   No necesitas programar un backend tradicional ni administrar servidores.
    
**Para quién es útil**

-   Proyectos **simples o medianos** (MVPs, prototipos, apps CRUD básicas).
-   Frontends que necesitan un backend **serverless rápido** sin complicaciones.
-   Equipos pequeños o junior que quieren enfocarse en **UI y lógica de negocio básica**.

## ECS (Elastic Container Service)

**¿Qué es ECS?**

Amazon ECS es un **servicio de AWS para ejecutar y administrar contenedores Docker**.

En vez de que tú levantes manualmente contenedores en una máquina, ECS se encarga de:

-   Ejecutarlos.    
-   Escalarlos (más instancias si hay mucho tráfico).    
-   Reiniciarlos si fallan.    
-   Balancear tráfico entre ellos.

**¿Para qué se usa ECS?**

Se usa cuando quieres **desplegar aplicaciones en contenedores** (ej. tu backend en Docker) sin tener que preocuparte de la infraestructura baja.
Algunos usos:
1.  **Aplicaciones web** (por ejemplo, tu API en Express o .NET corriendo en un contenedor).    
2.  **Microservicios** (cada microservicio corre en su propio contenedor).    
3.  **Jobs en segundo plano** (procesamiento de colas, tareas periódicas).    
4.  **Aplicaciones que escalan** (cuando necesitas que AWS levante más contenedores automáticamente según el tráfico).

 **Flujo completo de ECS con ECR**
1.  **Crear imagen Docker**
    -   Empaquetas tu aplicación (Node.js, Java, etc.) en un contenedor.        
    -   Ejemplo: `docker build -t miapp .`
        
2.  **Subir imagen a ECR (Elastic Container Registry)**   
    -   Creas un repositorio en ECR.        
    -   Haces login a ECR con Docker (`aws ecr get-login-password ...`).        
    -   Etiquetas la imagen y la subes:        
        `docker tag miapp:latest <tu-cuenta>.dkr.ecr.<region>.amazonaws.com/miapp:latest
        docker push <tu-cuenta>.dkr.ecr.<region>.amazonaws.com/miapp:latest` 
        
3.  **Crear un Cluster en ECS**    
    -   Defines si será con **EC2** (máquinas administradas por ti) o **Fargate** (serverless).  Esa elección es exactamente **dónde va a correr tu contenedor**     
   
    -   Ejemplo: “ClusterProducción”.
        
4.  **Definir Task Definition**    
    -   Aquí dices:        
        -   Usa la imagen que está en **ECR**.            
        -   Qué puertos expone.            
        -   Cuánto CPU y memoria asignar.            
        -   Variables de entorno.
             
    👉 La **Task Definition** es la receta que ECS usará para ejecutar tu contenedor.
    
5.  **Crear un Service**    
    -   Dices cuántas **Tasks** (contenedores) quieres mantener corriendo.        
    -   Ejemplo: mantener siempre 2 instancias de `miapp`.        
    -   ECS automáticamente reemplaza tareas caídas.
        
6.  **Configurar Networking (VPC, Subnets, Security Groups)**   
    -   Aquí decides si tu app es pública o privada.        
    -   Si es pública → necesitas un **Load Balancer (ALB o NLB)**.        
    -   Si es interna → basta con Security Groups + VPC.
        
7.  **ECS ejecuta los contenedores**    
    -   ECS baja tu imagen desde **ECR**.        
    -   Crea las tasks dentro del cluster (en Fargate o EC2).
        
8.  **Escalamiento**    
    -   Puedes configurar auto scaling (basado en CPU, memoria o requests).        
    -   Ejemplo: si el tráfico sube, de 2 tasks pasa a 5 tasks automáticamente.




## AWS Lambda

**AWS Lambda** es un servicio de **computación serverless** que te permite **ejecutar código sin aprovisionar ni administrar servidores**.  
Pagas **solo por el tiempo de ejecución** y la cantidad de invocaciones.


**¿Cómo funciona?**

- Tú subes una función (en Node.js, Python, Java, C#, Go, etc.).
- Lambda ejecuta esa función **cuando se activa un evento** (HTTP request, archivo en S3, mensaje en cola, etc.).
- No necesitas preocuparte de infraestructura: **AWS administra escalado, disponibilidad y servidores.**

**Casos de uso comunes**

1. **APIs Serverless**
   - Con **API Gateway + Lambda**, puedes crear APIs REST o GraphQL sin servidores.

2. **Procesamiento de archivos**
   - Ejemplo: cuando se sube una imagen a **S3**, Lambda la procesa (redimensiona, valida, etc.).

3. **Automatización**
   - Ejecutar tareas programadas (similar a cron jobs) usando **EventBridge/CloudWatch**.

4. **Integración con otros servicios AWS**
   - Responder a eventos de DynamoDB, Kinesis, SQS, SNS, etc.


**Ventajas**

- **Escalado automático** (desde 1 hasta miles de ejecuciones simultáneas).  
- **Pago por uso**: solo pagas por los milisegundos de ejecución.  
- **Integración nativa con AWS** (S3, DynamoDB, API Gateway, etc.).  
- Ideal para **microservicios y funciones pequeñas**.  


**Resumen**

AWS Lambda = **ejecutar funciones bajo demanda** sin servidores.  
Ideal para **APIs, automatizaciones, procesamiento de datos y microservicios**.  
Se paga solo por invocación y tiempo de uso.

## AWS API Gateway

**AWS API Gateway** es un servicio totalmente gestionado que te permite **exponer APIs seguras y escalables** para tus aplicaciones, ya sea REST, HTTP o WebSocket, **sin necesidad de administrar servidores**.  
Pagas **solo por las llamadas a la API y la transferencia de datos**.

**¿Cómo funciona?**

- Creas una API con rutas (endpoints) que exponen tus microservicios o funciones Lambda.  
- Cada endpoint puede integrarse con **Lambda, HTTP/HTTPS, otros servicios de AWS o mock responses**.  
- API Gateway maneja **enrutamiento, seguridad, escalado y monitoreo** automáticamente.

**Casos de uso comunes**

1. **APIs REST o HTTP para microservicios**  
   - Exponer endpoints de tus microservicios internos o serverless.

2. **Proxy para servicios existentes**  
   - Redirigir tráfico hacia APIs existentes o servicios externos.

3. **Autenticación y seguridad**  
   - Integración con **Cognito, JWT, API keys**, control de acceso y throttling.

4. **Transformación de datos**  
   - Cambiar formatos de request o response, agregar headers, validar payloads.

**Ventajas**

- **Escalado automático**: soporta miles de solicitudes simultáneas.  
- **Pago por uso**: solo pagas por llamadas a la API y transferencia de datos.  
- **Integración nativa con AWS**: Lambda, DynamoDB, S3, EventBridge, etc.  
- **Gestión centralizada de endpoints**: control de tráfico, versiones y stages.

**Resumen**
AWS API Gateway = **exponer y gestionar APIs de manera serverless**, integrando microservicios y funciones Lambda, con **seguridad, escalado y monitoreo automático**.  
Ideal para **APIs públicas o internas, microservicios y arquitecturas serverless**.



## IIS (Internet Information Services)
IIS, o Internet Information Services, es un servidor web desarrollado por Microsoft que se incluye en los sistemas operativos Windows para alojar y gestionar sitios web, aplicaciones y servicios en la red.

**🔹 1. Alojar sitios web**
Ejemplo:
Tienes un sitio HTML + CSS + JS estático o incluso un WordPress (PHP).
Lo subes a IIS → IIS sirve esos archivos al navegador de cualquier usuario que entre con http://miempresa.com.
Aquí el navegador pide un recurso (index.html) y IIS lo entrega.

**🔹 2. Alojar aplicaciones web**

Ejemplo:
Una aplicación en ASP.NET MVC o WebForms (.NET Framework).
La publicas en IIS.
IIS recibe las peticiones, levanta el pipeline de ASP.NET, procesa controladores, vistas, y responde con HTML/JSON.
Similar a como Tomcat aloja apps Java (Spring, JSP, Servlets).

**🔹 3. Alojar servicios en la red**

Ejemplo:
Un servicio SOAP (WCF) o servicio REST API (ASP.NET Web API o ASP.NET Core con hosting en IIS).
IIS maneja el ciclo de vida, las conexiones concurrentes y hasta balancea tráfico.
También puede servir FTP, SMTP (correo), WebDAV, etc.

---

En .NET Framework clásico (antes de .NET Core), IIS era obligatorio porque actuaba como el servidor web que alojaba directamente la aplicación.

En cambio, en .NET Core / .NET 5+, la aplicación ya trae su propio servidor embebido (Kestrel). Entonces, IIS ya no es el "servidor real", sino que se usa principalmente como:

🔹 Reverse Proxy delante de Kestrel:
- IIS recibe la petición HTTP/HTTPS.
- La redirige a tu aplicación .NET Core corriendo en Kestrel.
- De esa forma IIS aporta ventajas: SSL, compresión, balanceo básico, integración con Windows Authentication, logging, etc.

## Proxy

### **Proxy (Forward Proxy)**
Un proxy “normal” es un servidor intermedio que se ubica del lado del cliente.

**El cliente** le pide algo al proxy → el proxy lo reenvía al servidor.
**El servidor** cree que la petición vino del proxy, no del cliente.

👉 Ejemplo clásico:

Tú estás en una oficina y todas las computadoras navegan a Internet a través de un proxy corporativo.

Ese proxy puede filtrar, bloquear sitios o almacenar caché de respuestas.

**📌 Se usa principalmente para:**

- Control de acceso a Internet.
- Ocultar al cliente real.
- Mejorar seguridad y performance (con caché).

### **Reverse Proxy**

Un reverse proxy está del lado del servidor.

**El cliente** pide algo a midominio.com → esa petición llega primero al reverse proxy.
**El reverse** proxy decide a qué backend real enviarla (Spring Boot, .NET Core, etc.).

👉 Ejemplo con Nginx o IIS:

Tu backend en Spring Boot escucha en localhost:8091.

Pero el cliente nunca accede directo al puerto 8091.

El cliente pide https://api.miempresa.com → Nginx/IIS recibe esa petición → la reenvía internamente al backend en localhost:8091.

**📌 Se usa principalmente para:**

- Terminar conexiones HTTPS/SSL (el proxy maneja el certificado).
- Balancear carga (enviar tráfico a múltiples instancias).
- Hacer de “única puerta de entrada” a varios servicios backend.
- Seguridad (ocultar detalles del backend real).

**🔑 Diferencia corta:**

- Proxy normal: protege/representa al cliente.
- Reverse proxy: protege/representa al servidor.

## HTTP y HTTPS

Cuando ves una dirección que empieza con **HTTP** (ejemplo: `http://miapi.com`), significa que la comunicación entre tu computadora y el servidor **no va cifrada**.

🔹 **Qué significa no estar cifrada**

-   Todo lo que envías (contraseñas, correos, tokens, etc.) viaja como “texto claro”.    
-   Si alguien se mete en el medio (por ejemplo, alguien conectado al mismo WiFi que tú), puede **leer y robar** lo que estás enviando.   
-   A esto se le llama un **ataque de “man-in-the-middle”** (hombre en el medio).
    
🔹 **Qué pasa con HTTPS**  

Cuando usas **HTTPS** (ejemplo: `https://miapi.com`), el servidor tiene un **certificado SSL/TLS**.
-   Ese certificado permite **cifrar la comunicación** entre tu cliente y el servidor.    
-   Aunque alguien intercepte los datos, verá solo un montón de caracteres sin sentido.    
-   Además, el certificado prueba que estás hablando con el servidor correcto y no con un impostor.
    
👉 En simple:
-   **HTTP** = cualquiera puede mirar lo que mandas.    
-   **HTTPS** = tus datos viajan en una “caja fuerte” que solo tú y el servidor pueden abrir.


## Certificados SSL/TLS

### 1. Concepto
- Un **certificado SSL/TLS** es un archivo digital emitido por una **Autoridad Certificadora (CA)**.  
- Se usa para habilitar conexiones seguras en **HTTPS**.  
- Aunque se dice "SSL", hoy en día el protocolo real es **TLS** (SSL está obsoleto).  

### 2. Funciones principales
1. **Cifrado** → protege los datos entre cliente y servidor.  
2. **Autenticación** → asegura que el servidor es quien dice ser.  
3. **Integridad** → evita que los datos sean modificados en tránsito.  

### 3. Qué contienen
- Clave pública del servidor.  
- Nombre del dominio (ej. `api.midominio.com`).  
- Firma digital de la CA.  
- Fechas de validez.  

### 4. Tipos de certificados
- **DV (Domain Validation):** valida solo el dominio.  
- **OV (Organization Validation):** valida dominio + empresa.  
- **EV (Extended Validation):** validación más estricta (barra verde en algunos navegadores).  

### 5. Dónde se usan
- Se instalan en:
  - **Servidores web directos** (Apache, Nginx, IIS, Tomcat, Kestrel).  
  - **Reverse proxies / load balancers** (Nginx, AWS ALB, Cloudflare).  

### 6. Fuentes comunes
- **Gratuitos:** Let's Encrypt, AWS ACM (si usas AWS).  
- **De pago:** DigiCert, GoDaddy, Sectigo, etc.  

### 7. Importante
- "Certificado SSL" y "Certificado TLS" → **es lo mismo**.  
- Hoy en día el término correcto es **Certificado TLS**,  
  pero en la práctica se sigue diciendo "SSL" o "SSL/TLS".

