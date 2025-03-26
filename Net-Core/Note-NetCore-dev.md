# .Net Core ( C# )

1) Crear proyecto y Elegir (ASP.NET Core Web API)
2)  Para las otras capas elegir (Biblioteca de clases)

### Patrones de diseño 

**1) PATRONES DE REPOSITORY** 

 los patrones de diseño son soluciones probadas y documentadas a problemas comunes en el diseño de software, que permiten a los desarrolladores comunicarse de manera efectiva, reutilizar soluciones probadas y crear software de alta calidad y mantenible.

**Patrón Repositorio:** Este patrón se utiliza para abstraer y encapsular la lógica de acceso a datos en una capa separada de la lógica de negocio de la aplicación. Los repositorios proporcionan una interfaz común para interactuar con los datos y permiten cambiar fácilmente la fuente de datos subyacente sin afectar a otras partes del código.

**2) PATRONES INYECCION DEPENDENCIA** 

En su esencia, la inyección de dependencias es un mecanismo mediante el cual las dependencias requeridas por un componente se proporcionan desde el exterior, en lugar de que el componente las cree internamente. Esto permite una mayor flexibilidad, modularidad y testabilidad en el diseño de software.

**3) PATRON DTO** 

En el contexto de una API en .NET Core, los DTOs se utilizan para modelar y transferir datos entre el cliente y el servidor, especialmente en operaciones de entrada y salida de la API. Esto puede incluir datos enviados por el cliente en las solicitudes HTTP (DTOs de entrada) y datos devueltos por el servidor en las respuestas HTTP (DTOs de salida).

### ARQUITECTURA PROYECTO

Esta arquitectura se conoce como **Arquitectura en Capas (Layered Architecture)** o **Arquitectura Limpia (Clean Architecture)** con una separación clara de responsabilidades.

Este tipo de arquitectura divide el proyecto en capas bien definidas para **mantener un código modular, escalable y fácil de mantener**.

Cada capa tiene un **propósito específico**, evitando acoplamientos innecesarios.


### DESARROLLO PROYECTO

#### CAPA DE DOMAIN

**Responsabilidad:**
- Define entidades y reglas de negocio.
- No tiene dependencia en otras capas.
- Define interfaces de repositorios (pero no su implementación). 

#### CAPA DE INFRAESTRUCTURA 
Dependencias usadas:

- Entity Framework Core
- Entity Framework SqlServer
- Autofac.Extensions.DependencyInjection

**Responsabilidad:**
- Implementa acceso a datos usando Entity Framework Core.
- Se comunica con bases de datos y servicios externos (APIs, almacenamiento, etc.).
- Implementa interfaces definidas en Domain.

#### CAPA DE APPLICATION 

Dependencias usadas:
- AutoMapper
- AutoMapper.Extensions.Microsoft.Dependency
- FluentValidation.AspNetCore
- Autofac.Extensions.DependencyInjection

**Responsabilidad:**

-   Contiene la lógica de negocio de la aplicación.
-   Define **casos de uso** (por ejemplo, "Crear usuario", "Obtener usuario por ID").
-   Se comunica con los repositorios para obtener y guardar datos.

#### CAPA DE API - CONTROLLER

Dependencias usadas:
- Microsoft.AspNetCore.Authentication.JwtBearer
- Newtonsoft.Json
- Serilog.AspNetCore
- doble clik en el controller :
 < InvariantGlobalization >false< /InvariantGlobalization >
 
**Responsabilidad:**

-   Expone las API REST para que puedan ser consumidas por clientes (Frontend, móvil, otras APIs).
-   Maneja peticiones HTTP y respuestas.
-   Valida los datos antes de enviarlos a la lógica de negocio.
-   Implementa **autenticación y autorización**.


### SERILOG
- Serilog.AspNetCore

Si no instalaste nada y solo estás usando `ILogger<CategoriaService>`, **ASP.NET Core manejará los logs con su sistema de logging predeterminado (`Microsoft.Extensions.Logging`)**.

 **¿Qué pasa por defecto?**

1.  **El sistema de logging de ASP.NET Core está activado automáticamente**, así que `_logger.LogWarning(...)` funcionará sin problemas.
2.  Los logs generados por `_logger.LogWarning(...)` se enviarán a **la consola** si ejecutas la app en modo desarrollo.
3.  **No se guardarán en un archivo** a menos que configures explícitamente un proveedor de logs que escriba en archivo

**Qué pasa si agregas Serilog?**

Si después decides instalar **Serilog** . Entonces: 

✅ Los logs **ya no se manejarán por `Microsoft.Extensions.Logging`**, sino por Serilog.  
✅ Puedes configurar Serilog para guardar los logs en un archivo, base de datos o enviarlos a un sistema externo.

**`Serilog.AspNetCore` te permite reemplazar y mejorar el sistema de logs de ASP.NET Core con Serilog**, ofreciendo más opciones de personalización y almacenamiento de logs en múltiples destinos


### EXCEPTIONS

✅ **Middleware en ASP.NET Core**

-   Intercepta **solicitudes HTTP** en el servidor **antes** de llegar a los controladores.
-   Puede hacer cosas como **autenticación, logging, manejo de excepciones, CORS, etc.**
-   Se ejecuta en el **pipeline** de ASP.NET Core

En **ASP.NET Core**, las excepciones se manejan de forma centralizada y escalable mediante 
**Middleware de Excepciones**.
