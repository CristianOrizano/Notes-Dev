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
### MIDDLEWARES

En NestJS, los **middlewares** son funciones que se ejecutan antes de que una solicitud llegue a los controladores. Su objetivo es interceptar y manipular las solicitudes o respuestas, lo que los hace útiles para tareas como el registro de actividad (logging), autenticación, modificación de solicitudes, entre otros.

**¿Cuándo Usar un Middleware?**

Algunos casos comunes donde un middleware es útil:

-   **Registro de solicitudes (logging)**: Registrar cada solicitud que llega al servidor.
-   **Autenticación**: Verificar tokens o credenciales básicas antes de pasar la solicitud al guard o al controlador.
-   **Modificación de solicitudes**: Agregar o modificar datos en el objeto `request` antes de que llegue al controlador.
-   **Validación de datos**: Validar datos de la solicitud en un nivel básico.
**

**Middleware vs. Guard**

-   **Middleware**: Procesa la solicitud a nivel de aplicación o enrutamiento antes de llegar al controlador.
-   **Guard**: Procesa la solicitud en el controlador, para determinar la autorización o autenticación del usuario. Se usa para lógica más específica de autorización.

Este middleware registra en la consola el método HTTP y la URL de cada solicitud antes de continuar al controlador.
```typescript
@Injectable()
export class LoggerMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    console.log(`Request...`);
    console.log(`Method: ${req.method}, URL: ${req.url}`);
    next(); // Llama a la siguiente función en el ciclo de solicitud
  }
}

```
Para utilizar un middleware, debes aplicarlo en un módulo específico. Puedes hacerlo dentro del módulo usando el método `configure` en la clase de módulo y `apply` para asociar el middleware a rutas específicas.
```typescript
@Module({
  controllers: [UserController],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer
      .apply(LoggerMiddleware) // Aplica el middleware
      .forRoutes(UserController); // Específica las rutas
  }
}
```


### GUARDS

En NestJS, los **guards** son clases especiales que controlan el acceso a rutas o recursos específicos en función de ciertas condiciones o reglas de autorización. Son útiles para implementar la lógica de autorización y autenticación de una manera centralizada y reutilizable.

Un guard es una clase que implementa la interfaz `CanActivate`, la cual define un método `canActivate` que se ejecuta antes de que se procese una solicitud en un controlador o ruta específica. Basado en la lógica dentro de `canActivate`, el guard decide si permite (retornando `true`) o bloquea (retornando `false`) el acceso a la ruta.

```typescript
@Injectable()
export class AuthJWTGuard extends AuthGuard('jwt') {

	constructor(private reflector: Reflector) {
		super();
	}
	canActivate(context: ExecutionContext): boolean | Promise<boolean> | Observable<boolean> {
		const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
			context.getHandler(),
			context.getClass(),
		]);
		if (isPublic) {
			return true;
		}
		// Si no es pública, delega a la lógica de Passport para validar el token JWT(Strategy)
		return super.canActivate(context);
	}
}

```



**Guards Globales**
Puedes registrar un guard a nivel de aplicación, haciendo que se ejecute para cada solicitud entrante.
```typescript
@Module({
  providers: [
    {
      provide: APP_GUARD,
      useClass: AuthGuard,
    },
  ],
})
export class AppModule {}
```
 **Aplicar un Guard a una Ruta**

Para usar un guard, puedes aplicarlo a nivel de controlador o de ruta específica usando el decorador `@UseGuards`.
```typescript
@Controller('users')
export class UserController {
  @Get()
  @UseGuards(AuthGuard)
  findAll() {
    return 'Esta ruta está protegida por un guard.';
  }
}

```


### PIPES

En NestJS, un **pipe** es una clase que implementa una lógica específica de transformación o validación. Se utiliza principalmente para procesar, transformar y validar datos antes de que lleguen a un controlador o un servicio.

 Principales usos de los Pipes en NestJS

1.  **Transformación**: Convierte datos entrantes al formato que necesitas. Por ejemplo, transformar un parámetro de ruta de tipo `string` a un `number`.
    
2.  **Validación**: Verifica si los datos cumplen ciertos criterios y lanza una excepción si no lo hacen. Esto ayuda a mantener la lógica de validación centralizada y organizada.


Uno de los pipes más comunes es `ParseIntPipe`, que convierte automáticamente un parámetro de tipo `string` en `number`. Si el valor no puede convertirse a un número, el pipe lanza una excepción.
```typescript
@Get(':id') async findOne(@Param('id', ParseIntPipe) id: number) { 
// Aquí, `id` ya es un `number`, gracias a `ParseIntPipe`
}

```
#### Pipes Personalizados

NestJS permite crear pipes personalizados para implementar una lógica de validación o transformación específica que no esté cubierta por los pipes incorporados. Estos pipes personalizados deben implementar la interfaz `PipeTransform` y definir el método `transform`, donde se coloca la lógica de procesamiento
```typescript
@Injectable()
export class ParseBooleanPipe implements PipeTransform {
  transform(value: string): boolean {
    console.log('Valor recibido:', value); // Imprime el valor recibido
    if (value === 'true') return true;
    if (value === 'false') return false;
    throw new BadRequestException('Validation failed');
  }
}

@Get(':active')
async findActive(@Param('active', ParseBooleanPipe) active: boolean) {
  // `active` ahora es un booleano en lugar de un string
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


