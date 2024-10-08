# Framework (EXPRESS )
1) Instalar EXPRESS

- https://expressjs.com/

- npm install express --save

2) Estenciones VCODE

- Prettier-Code formatter
- Material Icon Theme

### SEND

send es un método utilizado para enviar una respuesta HTTP desde el servidor al cliente. Este método está disponible en el objeto res (que representa la respuesta HTTP) y se utiliza para enviar diferentes tipos de respuestas, como texto, HTML, JSON, archivos, etc.

```typescript
const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.send('¡Hola, mundo!');
});

app.listen(3000, () => {
  console.log('Servidor iniciado en http://localhost:3000');
});
```
###  Routing

El enrutamiento se refiere a cómo una aplicación responde a las solicitudes de un cliente a un endpoint particular, que es una URL específica y un método HTTP (como GET, POST, PUT, DELETE).

```typescript
const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.send('¡Hola, mundo!');
});

app.get('/usuario', (req, res) => {
  res.send('Obteniendo información del usuario');
});

app.post('/usuario', (req, res) => {
  res.send('Creando un nuevo usuario');
});

app.put('/usuario', (req, res) => {
  res.send('Actualizando información del usuario');
});

app.delete('/usuario', (req, res) => {
  res.send('Eliminando usuario');
});

app.use((req, res) => {
  res.status(404).send('No se encontro tu pagina');
});

app.listen(3000, () => {
  console.log('Servidor escuchando en el puerto 3000');
});
```
### Request Params

En Node.js con Express, los "request params" se refieren a los parámetros que se pasan en la URL de una solicitud HTTP. Estos parámetros son parte de la URL y se utilizan para enviar información específica al servidor. En Express, puedes acceder a estos parámetros utilizando req.params.


-- Ruta que espera un parámetro llamado userId
```typescript
app.get('/users/:userId', (req, res) => {
  const userId = req.params.userId;
  res.send(`El ID del usuario es: ${userId}`);
});

// Iniciar el servidor
app.listen(3000, () => {
  console.log('Servidor iniciado en http://localhost:3000');
});
```

###  Queries

Los parámetros de consulta son una forma común de enviar datos adicionales a través de la URL en una solicitud HTTP GET. Estos parámetros se especifican después del símbolo de interrogación ? en la URL y están en el formato clave=valor, separados por & si hay múltiples parámetros.
```typescript
const express = require('express');
const app = express();

// Ruta para obtener detalles de productos con parámetros de consulta
app.get('/products', (req, res) => {
  // Ejemplo de parámetros de consulta: /products?id=1&category=electronics
  const productId = req.query.id; // Obtener el valor del parámetro 'id'
  const category = req.query.category; // Obtener el valor del parámetro 'category'
  
  // Aquí podrías utilizar estos parámetros para realizar consultas en la base de datos
  // (En este ejemplo, simularemos una respuesta estática)
  let response = 'Detalles de productos:';
  if (productId) {
    response += ` Product ID: ${productId}`;
  }
  if (category) {
    response += ` Category: ${category}`;
  }

  res.send(response);
});

// Iniciar el servidor
app.listen(3000, () => {
  console.log('Servidor iniciado en http://localhost:3000');
});
```

- app.all(...)  => permite que funcione con todos los metodos.

###  Middlewares

En Express, un middleware es una función que tiene acceso al objeto request (solicitud req) y al objeto response (respuesta res) de una aplicación Express. Estas funciones pueden ejecutar código, realizar modificaciones en los objetos de solicitud y respuesta, finalizar el ciclo de solicitud-respuesta, o llamar al siguiente middleware en la pila de middleware.

```typescript
const express = require('express');
const app = express();

// Middleware de ejemplo que registra cada solicitud
app.use((req, res, next) => {
  console.log(`Solicitud recibida: ${req.method} ${req.url}`);
  next(); // Llama al siguiente middleware
});

// Ruta de ejemplo que usa un middleware específico
app.get('/ejemplo', (req, res) => {
  res.send('Respuesta de ejemplo');
});
```
### Request Body
Al usar express.json(), estás indicando al backend que debe estar preparado para recibir y procesar solicitudes cuyo cuerpo contiene datos en formato JSON. Esto es crucial para las aplicaciones web modernas, donde las solicitudes HTTP a menudo contienen datos JSON enviados por el cliente.

Middleware express.json(): Es un middleware que procesa y convierte el cuerpo de las solicitudes con contenido JSON en objetos JavaScript.

```typescript
const app =  express();

//anliza texto
app.use(express.text())

// Middleware para analizar JSON
app.use(express.json());

app.post('/user',(req,res))=>{
  console.log(req.body) 
  res.send('Nuevo usuario creado ')
}
```

### Express Settings

En Node.js, al usar Express, puedes configurar diversas opciones de la aplicación utilizando los "Express Settings" (configuraciones de Express). Estas configuraciones permiten ajustar el comportamiento de tu aplicación de Express según tus necesidades.

```typescript
const express = require('express');
const app = express();

// Configuración del entorno
app.set('env', 'development');

// Confiar en el proxy
app.set('trust proxy', true);

// Número de espacios para JSON
app.set('json spaces', 2);

// Sensibilidad a mayúsculas en rutas
app.set('case sensitive routing', true);

// Rutas estrictas
app.set('strict routing', true);

// Motor de vistas
app.set('view engine', 'ejs');

// Directorio de vistas
app.set('views', './views');

// Obtener el valor de la configuración
const env = app.get('env');
console.log(env); // development

```
### Express Router
Express Router es una característica de Express.js que te permite organizar las rutas de tu aplicación de manera modular y estructurada. Esto es especialmente útil cuando tienes una aplicación con muchas rutas o cuando deseas dividir tu aplicación en varios módulos o microservicios.
```typescript

// Importar Express
const express = require('express');
// Crear un nuevo Router
const router = express.Router();

// Definir rutas en el Router
router.get('/', (req, res) => {
  res.send('Bienvenido al sitio principal');
});

router.get('/about', (req, res) => {
  res.send('Acerca de nosotros');
});

// Exportar el Router para usarlo en otros archivos
module.exports = router;
---------------------------------------------------

const express = require('express');
const app = express();

// Importar el Router creado
const mainRouter = require('./routes/main');

// Usar el Router en la aplicación
app.use('/', mainRouter); o app.use(mainRouter);

// Iniciar el servidor
const port = 3000;
app.listen(port, () => {
  console.log(`Servidor ejecutándose en el puerto ${port}`);
});

```

### dotenv 

- npm install dotenv

-- dotenv es un módulo para Node.js que permite cargar variables de entorno desde un archivo .env en process.env. Es muy útil para separar la configuración sensible y específica del entorno de la aplicación del código fuente, como las claves API, configuraciones de base de datos, y otros parámetros de configuración.

Crea un archivo llamado .env en la raíz de tu proyecto. Aquí es donde almacenarás tus variables de entorno. Por ejemplo:

PORT=3000
DB_HOST=localhost
DB_USER=root
DB_PASS=password

```typescript
require('dotenv').config();

// Ahora puedes acceder a tus variables de entorno usando process.env
const express = require('express');
const app = express();

const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});

```

### NOTAS
Buenas Prácticas
Nunca subas el archivo .env a tu repositorio: Asegúrate de agregar .env a tu archivo .gitignore para que no se suba a tu repositorio de control de versiones.

Usa variables de entorno para configuraciones sensibles: Es una buena práctica mantener información sensible y específica del entorno fuera de tu código fuente.

Configura variables de entorno para diferentes entornos: Puedes tener diferentes archivos .env para distintos entornos (desarrollo, pruebas, producción) y cargar el archivo correcto dependiendo del entorno en el que se esté ejecutando tu aplicación.
