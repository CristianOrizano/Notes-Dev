
# Framework (Nest.js)

NestJS es un framework de Node.js que se utiliza para construir aplicaciones del lado del servidor eficientes, escalables y mantenibles. Está basado en TypeScript (aunque también puede usarse con JavaScript) y combina elementos de programación orientada a objetos (POO), programación funcional y programación reactiva. NestJS se destaca por su estructura modular y su enfoque en mejorar la productividad del desarrollo de aplicaciones backend.



**1) Intalar Nest JS**

- npm install -g @nestjs/cli

**2) Verificar Instalacion**

- nest -v

- nest => todos los comandos

**3) Crear Proyecto**

- nest new App-Crud-NestJS


**4) Poner el el eslint la siguiente regla, si hay error:**
```typescript
  "prettier/prettier": [
    "error",
    {
      "endOfLine": "auto"
    }	
  ]
```
### Comandos  mas comunes

 **Modulo**

- nest g module category

-  --flat  (no genera carpeta adicional)

 **Controlador**

- nest g controller category

 **Services**

- nest g service category

**Guard**

- nest g guard auth

**Interceptors**
- nest g interceptor logging

**Pipes**
- nest g pipe validation

**Middleware**
- nest g middleware logger

### TYPE ORM

TypeORM es un ORM (Object-Relational Mapping) que permite a los desarrolladores trabajar con bases de datos relacionales en aplicaciones de Node.js y TypeScript de manera más sencilla y eficiente. 

- npm install --save @nestjs/typeorm typeorm mysql2

```typescript
@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'mysql',
      host: 'localhost',
      port: 3306,
      username: 'test',
      password: 'test',
      database: 'test',
      entities: [User],
      synchronize: true,
    }),
    TypeOrmModule.forFeature([User]),
  ],
  controllers: [UserController],
  providers: [UserService],
})
export class AppModule {}

```
### Variables de entorno 

Es muy recomendable utilizar variables de entorno para gestionar datos sensibles y configuraciones que pueden variar entre los entornos de desarrollo, prueba y producción.

- npm install @nestjs/config

```typescript
  ConfigModule.forRoot({
      isGlobal: true, // Hacer que las variables estén disponibles globalmente
    }),

//Archivo .env 

DB_TYPE=mysql
DB_HOST=localhost
DB_PORT=3306
DB_USERNAME=test
DB_PASSWORD=test
DB_DATABASE=test

//Modulo principal
@Module({
  imports: [
    ConfigModule.forRoot(), // Cargar variables de entorno
    TypeOrmModule.forRootAsync({
      useFactory: (configService: ConfigService) => ({
        type: configService.get<string>('DB_TYPE') as 'mysql',
        host: configService.get<string>('DB_HOST'),
        port: +configService.get<number>('DB_PORT'), // Convertir a número
        username: configService.get<string>('DB_USERNAME'),
        password: configService.get<string>('DB_PASSWORD'),
        database: configService.get<string>('DB_DATABASE'),
        entities: [User],
        synchronize: true,
      }),
      inject: [ConfigService], // Inyectar ConfigService para acceder a las variables
    }),
    TypeOrmModule.forFeature([User]),
  ],
  controllers: [UserController],
  providers: [UserService],
})
export class AppModule {}

```
### Swager 

- npm install --save @nestjs/swagger

> En nest-cli.json  colocar 
> 
-  "plugins": ["@nestjs/swagger"] 
permite la generación automática de documentación de API basada en tus decoradores y DTOs.

```typescript
async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Configuración de Swagger
  const config = new DocumentBuilder()
    .setTitle('API Example') // Título de la API
    .setDescription('The API description') // Descripción de la API
    .setVersion('1.0') // Versión de la API
    .addTag('users') // Etiquetas para organizar los endpoints
    .build();
  
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api', app, document); // Ruta para acceder a la documentación

  await app.listen(3000);
}
bootstrap();

```
### CORS

CORS, que significa Cross-Origin Resource Sharing (Intercambio de Recursos de Origen Cruzado), es un mecanismo de seguridad implementado en los navegadores web que permite o restringe las solicitudes HTTP de un dominio a otro.

CORS permite a los servidores especificar quién puede acceder a sus recursos y desde qué orígenes se permiten las solicitudes. Esto es útil para APIs que necesitan ser consumidas desde diferentes dominios.

Encabezados CORS:

El servidor puede enviar encabezados específicos en la respuesta HTTP para indicar si se permite el acceso desde otros orígenes. Algunos de los encabezados más comunes son:
- Access-Control-Allow-Origin: Especifica qué orígenes pueden acceder al recurso. Puede ser un dominio específico o * (cualquiera).
- Access-Control-Allow-Methods: Indica qué métodos HTTP (GET, POST, PUT, DELETE, etc.) están permitidos.
- Access-Control-Allow-Headers: Especifica qué encabezados se pueden usar en la solicitud.

Permitir el acceso a tu API desde diferentes dominios y facilitar la comunicación entre tu frontend y backend en aplicaciones web

- app.enableCors()

### Validaciones 
NestJS utiliza la biblioteca `class-validator` para manejar la validación de datos en los DTOs (Data Transfer Objects). Esto permite definir reglas de validación directamente en las clases usando decoradores.

- npm i --save class-validator class-transformer


 En el main colocar
 
```typescript
 app.useGlobalPipes(new ValidationPipe({
   whitelist: true, // Elimina propiedades no definidas en el DTO 
   forbidNonWhitelisted: true, // Lanza un error si hay propiedades no permitidas
   transform: true, // Transforma automáticamente la solicitud en el DTO correspondiente
  }));
```
```typescript
import { IsString, IsEmail, IsNotEmpty } from 'class-validator';

export class CreateUserDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsEmail()
  email: string;
}
```

### Automapper 
AutoMapper es una biblioteca que facilita la asignación de propiedades entre diferentes objetos, como DTOs y entidades de base de datos. En NestJS, puedes utilizar AutoMapper para simplificar la transformación de datos y mejorar la mantenibilidad del código


- npm i @automapper/core @automapper/nestjs

- npm i @automapper/classes reflect-metadata --legacy-peer-deps

### JWT


- npm install @nestjs/jwt @nestjs/passport passport passport-jwt bcryptjs

- npm install @nestjs/jwt @nestjs/passport passport passport-jwt bcryptjs --legacy-peer-deps


> passport

- El uso de Passport en combinación con NestJS para la autenticación con JWT (JSON Web Tokens) ofrece una serie de beneficios y facilita la implementación de autenticación, especialmente cuando se utilizan estrategias predefinidas y extensibles, como la estrategia JWT. 

- Passport ofrece una estructura modular para manejar diferentes estrategias de autenticación (JWT, OAuth2, Local, etc.). Esto hace que sea fácil cambiar o agregar nuevas estrategias en el futuro.
Al usar @nestjs/passport, puedes reutilizar la estrategia de JWT en diferentes controladores sin necesidad de reescribir la lógica de validación en cada guardia personalizado.


- Aunque el token JWT tenga una duración de una hora, la verificación en el método validate se ejecuta cada vez que el usuario intenta acceder a una ruta protegida

- Si el usuario inicia sesión y recibe un token válido, pero luego, a los 15 minutos, su estado cambia a false en la base de datos (por ejemplo, si es desactivado manualmente por un administrador), la próxima vez que intente acceder a un recurso protegido, la función validate verificará su estado en la base de datos.

```typescript
async validate(payload: any) {
		// Buscar el usuario en la base de datos usando el ID del payload
		const user = await this.userService.findByIdAsycn(payload.sub);

		// Verificar si el usuario existe y si está activo
		if (!user || user.estado !== true) {
			throw new UnauthorizedException('User is not active or does not exist');
		}
		return user;
	}

@Module({
  imports: [
    TypeOrmModule.forFeature([User]),
    PassportModule,
    JwtModule.register({
      secret: 'your_jwt_secret', // Cambia esto por una clave más segura
      signOptions: { expiresIn: '1h' }, // Expiración del token
    }),
  ],
  providers: [AuthService, JwtStrategy],
  controllers: [AuthController],
})

```
