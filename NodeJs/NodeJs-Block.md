# NODE JS 
1) Instalar Node JS

- https://nodejs.org/en/download/prebuilt-installer/current

- node -v

Node.js como Entorno de Ejecución: Node.js proporciona un entorno de ejecución para JavaScript del lado del servidor. Al ejecutar node server.js, Node.js activa tu aplicación como un servidor web real, capaz de manejar solicitudes y servir respuestas a través del protocolo HTTP.

Node.js es versátil y puede utilizarse para crear tanto servidores web como ejecutar funciones y scripts simples. La distinción radica en cómo se estructura y qué funcionalidad se implementa en tu código. node server.js ejecutará el archivo server.js utilizando Node.js como entorno de ejecución, pero el tipo de aplicación que resulte depende completamente de cómo se haya diseñado el código en ese archivo.

### CONSOLA REPL
la consola REPL permite escribir código, ejecutarlo de inmediato y ver los resultados sin necesidad de escribir un archivo de programa separado. Es útil para probar ideas rápidamente, depurar código y experimentar con funciones o características del lenguaje de programación.

En el contexto de Node.js, la consola REPL se inicia cuando ejecutas el comando node en la terminal. Esto te permite interactuar con Node.js de manera directa, escribiendo y ejecutando código JavaScript de forma interactiva.

### OBJETOS GLOBALES
-  __dirname , __filename, module, require

###  TIMERS

- setInterval , setTimeout

### Modulos CommonJS

- Los módulos CommonJS se refieren a un sistema de módulos estándar utilizado en entornos como Node.js para organizar y reutilizar código JavaScript.

- En CommonJS, para exportar algo desde un módulo, utilizas module.exports. Esto puede ser cualquier valor de JavaScript: objetos, funciones, clases, primitivos, etc.

const mensaje = 'Hola Mundo';
module.exports = mensaje;

- Para importar un módulo exportado con module.exports, utilizas la función require en Node.js.

// otroArchivo.js

const mensaje = require('./archivo.js');
console.log(mensaje); // Imprime: Hola Mundo

###  MODULOS

- modulo OS, PATH, FS

- El módulo fs es esencial para muchas aplicaciones Node.js que necesitan interactuar con el sistema de archivos para realizar operaciones de lectura, escritura, manipulación y gestión de archivos y directorios.

- En resumen, la variable PATH es fundamental para el funcionamiento eficiente del sistema operativo al permitir el acceso rápido a programas y scripts instalados, sin necesidad de conocer la ruta completa de cada ejecutable.

- El módulo os es fundamental para tareas que requieren interacción con el entorno del sistema operativo en Node.js, proporcionando acceso directo a detalles críticos del sistema que son útiles para la administración y el desarrollo de aplicaciones robustas.

- HTTP
El módulo http en Node.js es fundamental para la creación de servidores HTTP y el manejo de solicitudes y respuestas HTTP. Permite a los desarrolladores construir aplicaciones web y servicios que pueden comunicarse a través del protocolo HTTP estándar. 

###  SERVIDOR

Un servidor es un sistema informático que proporciona servicios, datos o recursos a otros sistemas informáticos, denominados clientes, a través de una red. Los servidores son fundamentales para el funcionamiento de Internet y las redes internas de las empresas, ya que facilitan la comunicación y el intercambio de información entre múltiples dispositivos.

### FETCH - CLIENTE - SERVIDOR 

**Cliente**: La parte que hace la solicitud (tu aplicación, navegador, script, etc.).

**Servidor**: La parte que recibe la solicitud y responde con la información solicitada
 (JSONPlaceholder en este caso).
 
 ###   API(Application Programing interface)
 
 La API https://jsonplaceholder.typicode.com/posts actúa como un puente porque:

**Interpreta Solicitudes:** Recibe y entiende las solicitudes del cliente.

**Accede a Recursos:** Comunica estas solicitudes al servidor o base de datos que tiene los datos o servicios.

**Entrega Respuestas:** Recoge la respuesta del servidor y la devuelve al cliente en un formato que el cliente puede entender y usar.

Este proceso de intermediación es lo que convierte a las APIs en una herramienta esencial para la comunicación entre diferentes sistemas y aplicaciones.
-   **El servidor** escucha en un puerto específico y está preparado para recibir solicitudes.
-   **Los endpoints** son las rutas que los clientes utilizan para interactuar con tu aplicación.
-   Cada **endpoint** está asociado con un método HTTP y una lógica en el controlador, lo que permite que el servidor procese la solicitud y devuelva una respuesta adecuada.
