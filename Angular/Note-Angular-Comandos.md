# COMANDOS

1) **Atajos en VS CODE**

- Angular Snippets 
- Angular Language Service
- Angular Essentials
- Angular DevTools

2) **Comprobar que se haya instalado el Node en el comando de git**

- node -v
- npm -v


3) **Para instalar las carpetas del angular**

se debe instalar el CLI para crear proyectos, crear componentes y archivos
- npm install -g @angular/cli

para revisar que se instalo angular
- ng version

### Proyecto comandos

> **CREAR PROYECTO**
-   `ng new curso_angular` - Crea un nuevo proyecto Angular.
-   `cd curso_angular` - Navega al directorio del proyecto.
-   `code .` - Abre el proyecto en Visual Studio Code (si está instalado).

> **EJECUTAR PROYECTO**
- `ng serve -o` - Ejecuta el proyecto y abre automáticamente en el navegador.

> **ENTIDAD O INTERFACE**

-   `ng g class models/Admin --type=model` - Genera una clase en la carpeta `models` con el tipo `model`.
-   `ng g interface models/User` - Genera una interfaz en la carpeta `models`.

> **COMPONENTE**

- `ng g c components/CrudAdmin` - Genera un nuevo componente en la carpeta `components`.

> **ROUTING**

En Angular, el uso de comandos CLI como `ng generate` (o su alias `ng g`) generalmente resulta en la creación de carpetas y archivos con una estructura organizada para mantener tu proyecto limpio y modular.

`--flat`: Este flag indica que Angular CLI debe generar el archivo en el mismo nivel que el directorio especificado en lugar de crear una nueva subcarpeta para él. En este caso, `dashboard-routing.module.ts` se generará directamente en el directorio `dashboard` sin crear una carpeta adicional llamada `dashboard`.



- `ng g module app-routing --flat` - Genera un módulo de enrutamiento en el directorio raíz del proyecto.

- `ng g module dashboard/dashboard-routing --flat --routing` - Genera modulo pero adicional + te genera el routing(2modulos)

> **SERVICES**

- `ng g service services/data` - Genera un nuevo servicio en la carpeta `services`.
