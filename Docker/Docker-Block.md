# DOCKER

**¿Qué es Docker?**

Docker es una plataforma de software que permite crear, probar, implementar y ejecutar aplicaciones dentro de contenedores.

**¿Qué es un contenedor?** 

Un contenedor es una instancia en ejecución de una imagen de Docker. Es decir ejecuta la aplicacion en un entorno aislado y ligero de tal forma que funcione de la misma manera en diferentes entornos sin conflictos con el sistema operativo subyacente o con otras aplicaciones.

con aislado se refiere aque el contenedor crea un espacio independiente dentro de tu máquina donde tu aplicación puede ejecutarse sin interferir con otras aplicaciones o procesos del sistema operativo.


**¿Qué es una imagen?**

Una imagen de Docker es un archivo inmutable que contiene el código de la aplicación, sus dependencias y configuraciones necesarias para ejecutar la aplicación dentro de un contenedor.

El propósito de una imagen es servir como una **plantilla** para crear contenedores. Cada contenedor creado a partir de la imagen ejecutará la misma aplicación con las mismas dependencias, asegurando consistencia entre entornos.

### Instalar Docker 

- https://docs.docker.com/engine/install/

**Verificar instalacion**

- docker --version
- docker-compose --version

### Comandos más usados

**Listar contenedores activos:**

- `docker ps`

**Listar todos los contenedores (incluyendo los detenidos):**

- `docker ps -a`

**Ver imágenes descargadas:**

- `docker images`

**Descargar una imagen de Docker Hub:**

- `docker pull ubuntu`

**Crear y ejecutar un contenedor:**

- `docker run -it --name mi_contenedor node:18 bash`
  - `--name`: Es para nombre personalizado.
  - `-it`: Modo interactivo. Las opciones combinadas `-i` (interactivo) y `-t` (asignar un terminal) permiten que puedas interactuar con el contenedor, abriendo una shell
  -  ` bash (Bourne Again Shell) es un **intérprete de comandos** que se usa comúnmente en sistemas Linux y macOS.`

**Detener un contenedor:**

- `docker stop mi_contenedor`

**Eliminar un contenedor:**

- `docker rm mi_contenedor`

**Eliminar una imagen:**

- `docker rmi ubuntu`

**Iniciar un contenedor existente:**

- `docker start mi_contenedor`


### Dockerfile

**¿Qué es un Dockerfile?**

Un Dockerfile es un archivo de texto con instrucciones paso a paso para crear una imagen de Docker. Es como una receta que le dice a Docker cómo construir tu contenedor.

**Usando un Dockerfile, puedes definir:**

-   La imagen base sobre la que se construirá la nueva imagen.
-   Las dependencias que se instalarán.
-   Los archivos que se copiarán al contenedor.
-   Los comandos que se ejecutarán durante la construcción de la imagen.
-   La configuración del contenedor, como el puerto a exponer o el comando que debe ejecutarse cuando el contenedor se inicie.

#### Construir la imagen:

- `docker build -t mi-app .`
  - `-t mi-app`:  
    El flag `-t` (abreviatura de `--tag`) se utiliza para asignar un nombre y una etiqueta a la imagen que estás construyendo.  
    `mi-app` es el nombre de la imagen.  
    Por defecto, si no especificas una etiqueta, Docker asigna `latest`. Puedes definir una etiqueta específica así:  
    `docker build -t mi-app:v1.0 .`

  - `.` (punto al final):  
    Significa que Docker debe buscar el Dockerfile y todos los archivos necesarios para construir la imagen en el directorio actual.  
    Puedes especificar otro directorio si el Dockerfile está en un lugar diferente, por ejemplo:  
    `docker build -t mi-app /ruta/a/mi-directorio`

#### Ejecutar el contenedor:

- `docker run -d -p 3000:3000 --name mi-contenedor mi-app`

  - `-d`:  
    Ejecuta el contenedor en modo "desapegado" (detached), es decir, en segundo plano.

  - `-p 3000:3000`:  
    Mapea el puerto 3000 del contenedor al puerto 3000 de tu máquina local. Esto es útil para acceder a la aplicación que se está ejecutando dentro del contenedor.

  - `--name mi-contenedor`:  
    Asigna un nombre personalizado al contenedor (`mi-contenedor`), lo que facilita la gestión del contenedor.

  - `mi-app`:  
    Es el nombre de la imagen que acabas de construir, que se usará para crear el contenedor.
    
- ` docker start mi-contenedor`

  - el contenedor se **inicia con la configuración** que se especificó al crearlo inicialmente. Es decir, si al crear el contenedor con `docker run` usaste el flag `-p 3000:3000`, esta configuración de mapeo de puertos ya está asociada al contenedor, y al reiniciarlo con `docker start`, **ese mapeo de puertos permanecerá**.

  - Para volver a iniciar un contenedor que ya ha sido detenido
  
  
**EJEMPLO :**

```typescript
# Usar una imagen base de Node.js
FROM node:16

# Establecer el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiar los archivos del proyecto al contenedor
COPY package*.json ./

# Instalar las dependencias del proyecto
RUN npm install

# Copiar el resto de los archivos del proyecto
COPY . .

# Exponer el puerto en el que la aplicación escuchará
EXPOSE 3000

# Comando para iniciar la aplicación
CMD ["npm", "start"]

```
**Crear el contenedor de la base de datos MySQL**

Ahora, vamos a crear el contenedor de MySQL manualmente. Para ello, puedes usar el siguiente comando para ejecutar un contenedor de MySQL:

`docker run --name mi_mysql -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=node_back -p 3306:3306 -d mysql:8 `

-   `--name mi_mysql`: Le da el nombre `mi_mysql` al contenedor.
-   `-e MYSQL_ROOT_PASSWORD=root`: Establece la contraseña de `root` para la base de datos MySQL.
-   `-e MYSQL_DATABASE=node_back`: Crea una base de datos llamada `node_back`.
-   `-p 3306:3306`: Expone el puerto `3306` en el contenedor para que puedas acceder a la base de datos desde tu máquina local.
-   `-d`: Ejecuta el contenedor en segundo plano.
-   `mysql:8`: Usa la imagen de MySQL versión 8.



### Docker Exec, CMD y EntryPoint

**¿Para qué sirve `docker exec`?**

**`docker exec`** se utiliza para ejecutar comandos dentro de un contenedor **que ya está en ejecución**. Te permite interactuar con un contenedor en marcha sin necesidad de reiniciarlo o crear uno nuevo

1.  **Ejecutar comandos dentro de un contenedor en ejecución**: Puedes ejecutar comandos o iniciar procesos adicionales en un contenedor que ya está corriendo. Por ejemplo, puedes acceder a la terminal de un contenedor para ver los logs, inspeccionar archivos o ejecutar scripts.
    
2.  **Acceder al contenedor sin detenerlo**: Si el contenedor ya está en ejecución (por ejemplo, un servidor web o una base de datos), puedes acceder a su terminal para hacer tareas de mantenimiento o depuración sin detener el contenedor.

Esto te permitirá interactuar con el entorno de Node.js directamente en el contenedor, similar a lo que harías con `docker run -it node`.

Cuando uses `docker exec`, siempre necesitarás especificar al menos dos argumentos: el nombre del contenedor y el comando que deseas ejecutar dentro de ese contenedor.

- docker exec -it mi_contenedor node



**¿Para qué sirve `CMD y ENTRYPOINT`?**

En un `Dockerfile`, **`CMD`** y **`ENTRYPOINT`** son instrucciones utilizadas para definir el comportamiento predeterminado del contenedor cuando se ejecuta. Sin embargo, hay diferencias clave entre las dos:

-   **`CMD`**: Define el comando que se ejecutará cuando se inicie el contenedor **si no se proporciona un comando explícito al ejecutar `docker run`**.
-   **`ENTRYPOINT`**: Define el comando principal que siempre se ejecutará cuando se inicie el contenedor. 
-   **`ENTRYPOINT`** es ideal cuando deseas definir un comando fijo que debe ejecutarse siempre al iniciar el contenedor.
-   **`CMD`** es ideal para proporcionar valores predeterminados que pueden ser sobrescritos al ejecutar el contenedor.



### Docker Hub

**Docker Hub** es un servicio en línea que sirve como un **repositorio centralizado de imágenes de Docker**. Es un servicio proporcionado por Docker, Inc., que permite a los desarrolladores almacenar, compartir y distribuir imágenes de contenedores Docker. Docker Hub es una especie de "repositorio público" donde puedes encontrar una gran variedad de imágenes preconfiguradas (por ejemplo, imágenes de bases de datos, servidores web, aplicaciones populares, etc.) para utilizar en tus proyectos.

### Funcionalidades de Docker Hub:

1.  **Almacenar Imágenes Docker:**
    -   Puedes subir y almacenar imágenes personalizadas que has creado para tus proyectos. Esto facilita la distribución de tus aplicaciones a través de diferentes entornos y equipos.
2.  **Imágenes Públicas y Privadas:**
    -   Ofrece repositorios tanto **públicos** (donde cualquiera puede acceder y descargar las imágenes) como **privados** (donde solo las personas autorizadas pueden acceder).
3.  **Acceso a Imágenes de Terceros:**
    -   Docker Hub contiene una gran cantidad de **imágenes públicas** creadas por otros usuarios y organizaciones, incluidas imágenes oficiales de proyectos como **Node.js**, **MySQL**, **Redis**, **PostgreSQL**, entre otros. Esto te permite **evitar tener que crear tus propias imágenes** desde cero.
4.  **Automatización de Builds:**
    -   Docker Hub permite **automatizar el proceso de construcción de imágenes**. Puedes conectar tu repositorio de GitHub o Bitbucket y configurar **Webhooks** para que Docker Hub construya automáticamente nuevas imágenes cuando se hagan cambios en el código.
5.  **Versionado de Imágenes:**
    -   Puedes etiquetar diferentes versiones de tus imágenes para asegurar que puedas acceder a versiones anteriores o específicas cuando sea necesario.
6.  **Búsquedas y Documentación:**
    -   Puedes buscar imágenes públicas disponibles, y cada imagen tiene su documentación asociada para que sepas cómo usarla.

**Subir una imagen:** Después de construir una imagen localmente, puedes subirla a Docker Hub usando el comando `docker push`:

- docker push mi_usuario/mi_imagen:etiqueta


### Redes en Docker

**¿Qué son las redes en Docker?**
En Docker, una red permite que los contenedores se comuniquen entre sí y con otros servicios, ya sea en la misma máquina o en diferentes máquinas. Docker ofrece varios modos de redes para satisfacer diferentes necesidades de comunicación.

 **Tipos de Redes en Docker**

Docker ofrece varios tipos de redes por defecto:

#### 1. **Bridge (red por defecto)**

-   Es la red predeterminada para contenedores que no especifican otra red.
-   Permite que los contenedores conectados a la misma red "bridge" se comuniquen entre sí.
-   Cada contenedor obtiene su propia dirección IP privada en esta red.

#### 2. **Host**

-   Usa la pila de red del host directamente, es decir, no crea un entorno de red aislado para el contenedor.
-   Los contenedores que usan la red "host" comparten el mismo stack de red que la máquina anfitriona, incluyendo la misma IP.
-   Ideal para casos donde necesitas rendimiento máximo o acceso directo a los puertos de la máquina anfitriona.

#### 3. **None**

-   Desactiva toda la red para el contenedor.
-   Útil si deseas ejecutar contenedores completamente aislados, sin acceso a ninguna red.

#### 4. **Overlay**

-   Permite la comunicación entre múltiples hosts de Docker (usualmente en un clúster de Docker Swarm).
-   Se utiliza para redes distribuidas, lo que permite conectar contenedores en diferentes hosts de Docker.
-   Requiere un entorno de orquestación como Docker Swarm.

#### 5. **Macvlan**

-   Permite a los contenedores tener sus propias direcciones MAC y comportarse como dispositivos físicos en la red.
-   Útil para integrarse con redes físicas o si necesitas asignar una dirección IP específica de la red externa.

**Crear una red personalizada usando `docker network create`**

Puedes crear una red personalizada desde la línea de comandos de Docker. Por ejemplo, para crear una red llamada `my-custom-network` con el driver `bridge` (que es el predeterminado), puedes usar:

`docker network create --driver bridge my-custom-network`

**Listar la redes**
`docker network ls `

**Borrar la redes**
`docker network rm my-network `

 **Crear redes personalizadas con `docker-compose.yml`**

En un archivo `docker-compose.yml`, puedes definir redes personalizadas para tus contenedores. Aquí hay un ejemplo de cómo hacerlo:

```typescript
version: '3.8'

services:
  backend:
    image: my-backend-image
    networks:
      - app-network
    environment:
      - DB_HOST=mysql-db
      - DB_PORT=3306

  mysql-db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: password
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
```

En este caso, se ha creado una red personalizada llamada `app-network`, que utiliza el driver `bridge` (predeterminado). Los contenedores `backend` y `mysql-db` se conectan a esta red y pueden **comunicarse entre sí** usando sus nombres de contenedor, como `mysql-db:3306` para la base de datos.

**Comunicarse entre contenedores en redes personalizadas**

Una vez que los contenedores están en la misma red personalizada, pueden comunicarse entre sí usando los **nombres de contenedor** como hostnames. Por ejemplo, si el contenedor `backend` necesita conectarse a `mysql-db`, en lugar de usar una dirección IP, puede usar `mysql-db` como el nombre del host para la base de datos.



### Volumenes y Bind Mounts
En Docker, un **volumen** es un mecanismo utilizado para persistir datos de manera que sobrevivan a la eliminación y recreación de contenedores. Los volúmenes son un tipo de almacenamiento que no se encuentra dentro de la propia imagen del contenedor, sino que están gestionados por Docker y pueden ser compartidos entre varios contenedores.

Supongamos que quieres que una base de datos en un contenedor persista sus datos fuera del contenedor. Puedes hacer algo como:

- docker run -d --name mysql -v mysql-data:/var/lib/mysql mysql
  -   **`mysql-data`** es el volumen.
  -   **`/var/lib/mysql`** es el directorio dentro del contenedor donde MySQL guarda sus datos.
  
### Docker Compose

**Docker Compose** es una herramienta que facilita la definición y ejecución de aplicaciones multi-contenedor en Docker. Permite definir toda la configuración de los contenedores de una aplicación en un solo archivo YAML (`docker-compose.yml`), lo que simplifica la creación, configuración, y administración de aplicaciones que necesitan múltiples contenedores (por ejemplo, un servicio web, una base de datos, y un servidor de caché).

**EJEMPLO**
```typescript
Dockerfile

# 1. Usar la imagen oficial de Node.js como base
FROM node:18

# 2. Establecer el directorio de trabajo dentro del contenedor
WORKDIR /app

# 3. Copiar los archivos package.json y package-lock.json (si existe)
COPY package*.json ./

# 4. Instalar las dependencias
RUN npm install

# Copiar el resto del código fuente
COPY . .

# 6. Generar el cliente de Prisma
RUN npx prisma generate

# 7. Exponer el puerto en el que la API escuchará
EXPOSE 3000

# 7. Comando para ejecutar en modo desarrollo con hot-reload
CMD ["npm", "run", "dev"]
```
```typescript
docker-compose.yml

version: '3.8'

services:
  db:
    image: mysql:8.0
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: mysql
      MYSQL_DATABASE: node_back
    volumes:
      - mysql_data:/var/lib/mysql
    ports:
      - "3307:3306"  # Mapea el puerto 3307 de la máquina al puerto 3306 del contenedor
    networks:
      - my_network

  app:
    build:
      context: .
      dockerfile: Dockerfile
    restart: always
    env_file: .env
    volumes:
      - .:/app
      - node_modules:/app/node_modules  # Volumen nombrado para /app/node_modules
    ports:
      - "3000:3000"
    depends_on:
      - db
    networks:
      - my_network
 

volumes:
  mysql_data:
    driver: local
  node_modules:  # Definir el volumen 'node_modules' aquí
    driver: local


networks:
  my_network:
    driver: bridge

```
### Explicación del archivo `docker-compose.yml`:

1. **Versión de Compose:**
   - La propiedad **`version`** define la versión de la sintaxis que Docker Compose usará. En este caso, se está utilizando la versión **`3.8`**, que es compatible con muchas características de Docker actuales.

2. **Definición de Servicios:**
   - En Docker Compose, un **servicio** representa un contenedor que se ejecuta en tu aplicación. En este archivo, hay dos servicios definidos: **`db`** (base de datos MySQL) y **`app`** (aplicación Node.js).

3. **Servicio `db` (MySQL):**
   - **`image`**: Se utiliza la imagen oficial de MySQL, versión **`8.0`**.
   - **`restart`**: El servicio se reiniciará automáticamente si el contenedor falla.
   - **`environment`**: Define variables de entorno necesarias para configurar MySQL, como la contraseña del root y la base de datos a crear.
   - **`volumes`**: Se define un volumen persistente para almacenar los datos de MySQL, de modo que no se pierdan cuando el contenedor se reinicie.
   - **`ports`**: Mapea el puerto **`3307`** del host al puerto **`3306`** del contenedor, permitiendo acceder a MySQL desde fuera del contenedor.
   - **`networks`**: Conecta el contenedor a una red interna llamada **`my_network`** para que los contenedores puedan comunicarse entre sí.

4. **Servicio `app` (Node.js):**
   - **`build`**: Define cómo construir la imagen para el contenedor de la aplicación. Usa el contexto actual (directorio `.`) y el archivo **`Dockerfile`**.
   - **`restart`**: Al igual que `db`, el servicio **`app`** se reiniciará si falla.
   - **`env_file`**: Se utiliza un archivo `.env` para cargar las variables de entorno de la aplicación.
   - **`volumes`**: Se definen dos volúmenes:
     - **`.:/app`**: Mapea el código fuente del proyecto en el directorio actual al contenedor.
     - **`node_modules:/app/node_modules`**: Utiliza un volumen persistente para almacenar los módulos de Node.js, evitando que se sobrescriban al reiniciar el contenedor.
   - **`ports`**: Mapea el puerto **`3000`** del contenedor al puerto **`3000`** del host, permitiendo que la aplicación Node.js sea accesible desde el host.
   - **`depends_on`**: Este servicio depende del contenedor `db`, por lo que Docker Compose se asegura de que el contenedor de la base de datos se inicie antes que la aplicación.
   - **`networks`**: Al igual que `db`, conecta este contenedor a la red **`my_network`**.

5. **Definición de Volúmenes:**
   - **`mysql_data`**: Es un volumen persistente que almacena los datos de MySQL, asegurando que los datos no se pierdan cuando el contenedor de la base de datos se reinicie.
   - **`node_modules`**: Este volumen se utiliza para almacenar los módulos de Node.js, evitando que se sobrescriban cuando se reinicie el contenedor de la aplicación.

6. **Definición de Redes:**
   - **`my_network`**: Crea una red interna llamada **`my_network`** utilizando el driver **`bridge`**, lo que permite que los contenedores de la misma red puedan comunicarse entre sí.


**COMANDOS**
- `docker-compose up --build -d`: Construye las imágenes (si es necesario) y luego inicia los contenedores.
- `docker-compose up`: Inicia los contenedores.
- `docker-compose down`: Detiene y elimina los contenedores, redes y volúmenes.
- `docker-compose ps`: Muestra los contenedores activos.
- `docker-compose build`: Construye las imágenes.
- `docker-compose logs`: Muestra los logs de los contenedores.
- `docker-compose exec`: Ejecuta comandos en un contenedor en ejecución.
- `docker-compose run`: Ejecuta un comando en un nuevo contenedor.
- `docker-compose pull`: Descarga imágenes más recientes.
- `docker-compose push`: Empuja imágenes locales al repositorio.


