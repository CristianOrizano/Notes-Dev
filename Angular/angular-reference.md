# Angular — Temario de referencia rápida


## Fase 1 — Core de Angular

### Angular CLI y estructura de proyecto

**Angular CLI** es la herramienta de línea de comandos oficial de Angular. Con ella creas proyectos, generas componentes, ejecutas el servidor de desarrollo, corres tests y compilas para producción. Sin la CLI tendrías que configurar todo manualmente (webpack, TypeScript, etc).

```bash
ng new my-app                            # crea el proyecto
ng serve                                 # servidor de desarrollo en localhost:4200
ng generate component user               # genera un componente
ng build --configuration=production      # compila optimizado

```

**`angular.json`** es el archivo de configuración central del proyecto. Aquí defines qué estilos globales incluir, qué assets copiar al build, qué builder usar y cómo configurar cada environment. Si necesitas agregar Bootstrap o configurar un proxy para el backend, lo haces aquí.

**`tsconfig.json`** controla cómo TypeScript compila tu código. Los ajustes más importantes son `strict: true` (recomendado siempre) y `paths` para definir alias de imports (`@core`, `@shared`, etc).

**Environments** son archivos (`environment.ts`, `environment.prod.ts`) que contienen variables según el entorno como la URL del backend. Angular los intercambia automáticamente al compilar con el flag de configuración correcto.

```typescript
// environment.ts
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8080/api'
};

```

**Standalone vs NgModules** — Antes era obligatorio declarar cada componente dentro de un `NgModule`. Desde Angular 17+, los componentes son standalone por defecto: se autodeclaran e importan sus dependencias directamente. NgModules sigue existiendo pero ya es el enfoque legacy.

----------

### Componentes

Un **componente** es el bloque de construcción principal de Angular. Combina una clase TypeScript (lógica), un template HTML (vista) y estilos CSS. Todo lo que el usuario ve en pantalla es un árbol de componentes.

```typescript
@Component({
  selector: 'app-user-card',
  template: `<h2>{{ user.name }}</h2>`,
  styleUrl: './user-card.component.css'
})
export class UserCardComponent {
  user = { name: 'Cristian' };
}

```

**`@Input()` / `input()`** permiten que un componente padre le pase datos a un componente hijo. `input()` es la versión moderna basada en Signals (Angular 17+).

```typescript
// hijo
name = input<string>();   // versión moderna con signals

// padre en el template
<app-user-card [name]="'Cristian'" />

```

**`@Output()` / `output()`** permiten que el hijo le comunique eventos al padre. El hijo emite, el padre escucha.

```typescript
// hijo
saved = output<User>();
onSave() { this.saved.emit(this.user); }

// padre en el template
<app-form (saved)="handleSave($event)" />

```

**`ViewChild`** te da acceso desde la clase TypeScript a un elemento del propio template (un input, un componente hijo, etc). Se usa cuando necesitas manipular algo del DOM o llamar un método del hijo directamente.

```typescript
@ViewChild('myInput') inputRef!: ElementRef;
ngAfterViewInit() { this.inputRef.nativeElement.focus(); }

```

**`ng-content`** es proyección de contenido. Permite que quien use tu componente inyecte HTML dentro de él, como si fuera un slot. Es como el `children` de React.

```html
<!-- definición del componente card -->
<div class="card">
  <ng-content></ng-content>
</div>

<!-- uso -->
<app-card>
  <p>Este párrafo se proyecta dentro del card</p>
</app-card>

```

----------

### Lifecycle Hooks

Los lifecycle hooks son métodos que Angular llama automáticamente en momentos específicos del ciclo de vida de un componente. Te permiten ejecutar código en el momento justo: cuando el componente nace, cuando cambian sus datos, o cuando muere.

Hook

Cuándo usarlo

`ngOnChanges`

Reaccionar a cambios en `@Input()`. Recibes los valores anteriores y nuevos.

`ngOnInit`

Inicialización: llamadas HTTP, suscripciones, lógica de arranque. Se ejecuta una sola vez.

`ngAfterViewInit`

Cuando necesitas acceder a elementos del DOM o hijos vía `@ViewChild`.

`ngOnDestroy`

Limpiar suscripciones, timers o listeners para evitar memory leaks.

```typescript
export class MyComponent implements OnInit, OnDestroy {
  private sub!: Subscription;

  ngOnInit() {
    this.sub = this.service.getData().subscribe();
  }

  ngOnDestroy() {
    this.sub.unsubscribe(); // evita memory leak
  }
}

```

----------

### Templates y Data Binding

El **data binding** es el mecanismo por el que Angular sincroniza los datos de la clase TypeScript con el template HTML y viceversa. Existen cuatro formas:

**Interpolación `{{ }}`** — Muestra un valor del componente en el HTML. Solo lectura, del componente al template.

```html
<p>Bienvenido, {{ user.name }}</p>

```

**Property binding `[ ]`** — Enlaza una propiedad del DOM o un `@Input()` con un valor del componente.

```html
<button [disabled]="isLoading">Guardar</button>
<app-card [title]="pageTitle" />

```

**Event binding `( )`** — Escucha eventos del DOM y ejecuta código del componente.

```html
<button (click)="onSave()">Guardar</button>
<input (keyup.enter)="onSearch()" />

```

**Two-way binding `[( )]`** — Combina property y event binding. Si cambia el dato en el componente, se actualiza el input; si el usuario escribe, se actualiza el dato.

```html
<input [(ngModel)]="email" />

```

**Template reference variable `#`** — Le da un nombre a un elemento del template para referenciarlo desde el mismo template o desde `@ViewChild`.

```html
<input #searchInput />
<button (click)="search(searchInput.value)">Buscar</button>

```

----------

### Control Flow — Nueva sintaxis (Angular 17+)

Angular 17 introdujo una nueva sintaxis de control de flujo directamente en los templates, reemplazando las directivas antiguas `*ngIf`, `*ngFor` y `*ngSwitch`. Es más legible y más performante.

**`@if / @else`** — Muestra u oculta contenido según una condición.

```html
@if (user) {
  <p>Hola, {{ user.name }}</p>
} @else {
  <p>No hay usuario</p>
}

```

**`@for`** — Itera una colección. El `track` es obligatorio: le dice a Angular cómo identificar cada item para no re-renderizar todo cuando cambia la lista.

```html
@for (doctor of doctors; track doctor.id) {
  <app-doctor-card [doctor]="doctor" />
}

```

**`@defer`** — Carga una parte del template de forma lazy, solo cuando se cumple una condición. Reduce el bundle inicial.

```html
@defer (on viewport) {
  <app-heavy-chart />
} @placeholder {
  <p>Cargando gráfico...</p>
}

```

----------

### Pipes

Un **pipe** es un transformador de datos para usar en el template. Toma un valor, lo transforma y muestra el resultado. No modifica el dato original.

```html
{{ fecha | date:'dd/MM/yyyy' }}
{{ precio | currency:'USD' }}
{{ nombre | uppercase }}
{{ datos$ | async }}   <!-- se suscribe y desuscribe automáticamente -->

```

El **pipe async** es especialmente importante: recibe un Observable o Promise, se suscribe automáticamente y muestra el valor emitido. Cuando el componente se destruye, se desuscribe solo.

**Pipe personalizado** — Cuando ningún pipe built-in hace lo que necesitas, creas el tuyo. Implementa `transform(value, ...args)`.

```typescript
@Pipe({ name: 'truncate', standalone: true })
export class TruncatePipe implements PipeTransform {
  transform(value: string, limit = 50): string {
    return value.length > limit ? value.slice(0, limit) + '...' : value;
  }
}
// uso: {{ descripcion | truncate:100 }}

```

----------

### Directivas

Una **directiva de atributo** modifica el comportamiento o apariencia de un elemento HTML existente sin cambiar su estructura. Es como un componente pero sin template propio.

```typescript
@Directive({ selector: '[appHighlight]', standalone: true })
export class HighlightDirective {
  @HostListener('mouseenter') onEnter() {
    this.el.nativeElement.style.background = 'yellow';
  }
  constructor(private el: ElementRef) {}
}
// uso: <p appHighlight>Pásame el mouse</p>

```

Una **directiva estructural** modifica el DOM agregando o eliminando elementos. `@if` y `@for` son las built-in. Para crear una custom se usa `TemplateRef` + `ViewContainerRef`.

----------

## Fase 2 — Servicios, Rutas, HTTP, Formularios

### Servicios e Inyección de Dependencias (DI)

Un **servicio** en Angular es una clase diseñada para encapsular lógica de negocio, acceso a datos u otras funcionalidades que pueden ser compartidas entre múltiples componentes. La idea es que los componentes solo se encarguen de la vista, y todo el resto vive en servicios.

La **Inyección de Dependencias (DI)** es el mecanismo por el que Angular se encarga de crear y proveer estas instancias. Tú simplemente declaras que necesitas un servicio y Angular te lo entrega; no necesitas hacer `new MiServicio()`.

```typescript
// Definir el servicio
@Injectable({ providedIn: 'root' }) // singleton global
export class AppointmentService {
  private http = inject(HttpClient);

  getAll() {
    return this.http.get<Appointment[]>('/api/appointments');
  }
}

// Usar el servicio en un componente
@Component({ ... })
export class AppointmentListComponent {
  private service = inject(AppointmentService); // Angular lo crea y entrega
}

```

**`providedIn: 'root'`** crea una sola instancia del servicio para toda la app (singleton). Si lo provees en un componente específico con `providers: [MiServicio]`, Angular crea una instancia independiente solo para ese componente y sus hijos.

**`InjectionToken`** sirve cuando quieres inyectar algo que no es una clase, como un objeto de configuración o un valor primitivo.

```typescript
export const API_URL = new InjectionToken<string>('API_URL');

// al registrarlo
providers: [{ provide: API_URL, useValue: 'http://localhost:8080' }]

// al usarlo
private apiUrl = inject(API_URL);

```

**`useClass` / `useValue` / `useFactory` / `useExisting`** son formas de decirle a Angular cómo construir o resolver una dependencia. Por ejemplo, `useClass` permite que cuando alguien pida `LoggerService`, Angular entregue `ConsoleLoggerService` en su lugar. Útil para mocks en testing o para intercambiar implementaciones.

----------

### Routing

El **Router de Angular** es el sistema que permite navegar entre vistas sin recargar la página (SPA). Cada ruta mapea una URL a un componente.

```typescript
// app.routes.ts
export const routes: Routes = [
  { path: '', component: HomeComponent },
  { path: 'patients', component: PatientListComponent },
  { path: 'patients/:id', component: PatientDetailComponent },
  {
    path: 'dashboard',
    loadComponent: () => import('./dashboard/dashboard.component'),
    canActivate: [authGuard]
  }
];

```

**Lazy loading** es clave para performance: el código de una ruta no se descarga hasta que el usuario navega a ella por primera vez. Reduce el bundle inicial de la app.

**Guards** son funciones que deciden si se puede entrar o salir de una ruta. El caso más común es proteger rutas que requieren autenticación.

```typescript
// guard funcional (Angular 15+)
export const authGuard: CanActivateFn = () => {
  const auth = inject(AuthService);
  return auth.isLoggedIn() ? true : inject(Router).createUrlTree(['/login']);
};

```

**Resolver** precarga datos antes de activar la ruta. El componente recibe los datos ya listos sin necesidad de mostrar un spinner dentro del componente.

```typescript
export const doctorResolver: ResolveFn<Doctor> = (route) => {
  return inject(DoctorService).getById(route.paramMap.get('id')!);
};

```

**Rutas anidadas** permiten tener layouts con secciones que cambian. El componente padre tiene su propio `<router-outlet>` donde se renderizan los hijos.

----------

### Formularios

Angular ofrece dos enfoques para formularios. La diferencia principal es dónde vive la lógica: en el template o en la clase TypeScript.

**Template-driven forms** — La lógica está en el template mediante directivas (`ngModel`, `required`, etc). Simple de usar pero difícil de testear y de escalar.

```html
<form #form="ngForm" (ngSubmit)="onSubmit(form)">
  <input name="email" [(ngModel)]="email" required email />
  <button [disabled]="form.invalid">Enviar</button>
</form>

```

**Reactive forms** — La lógica está en la clase TypeScript. Son más verbosos pero más poderosos, más testeables y recomendados para cualquier formulario que no sea trivial.

```typescript
form = this.fb.group({
  email: ['', [Validators.required, Validators.email]],
  password: ['', Validators.minLength(8)]
});

onSubmit() {
  if (this.form.valid) console.log(this.form.value);
}

```

**`FormArray`** se usa cuando tienes una lista dinámica de controles, por ejemplo una lista de teléfonos que el usuario puede agregar y quitar.

**Validadores personalizados** son funciones que reciben el control y retornan un objeto de error o `null` si es válido.

```typescript
function noSpaces(control: AbstractControl): ValidationErrors | null {
  return control.value?.includes(' ') ? { noSpaces: true } : null;
}

```

**Validadores asíncronos** hacen una llamada al backend para validar (ej: verificar si un email ya está registrado). Retornan un Observable.

----------

### HTTP Client

`HttpClient` es el servicio de Angular para comunicarse con APIs REST. Todos sus métodos retornan Observables, lo que los hace integrables con RxJS y con el pipe `async`.

```typescript
@Injectable({ providedIn: 'root' })
export class PatientService {
  private http = inject(HttpClient);
  private apiUrl = 'http://localhost:8080/api/patients';

  getAll()             { return this.http.get<Patient[]>(this.apiUrl); }
  getById(id: string)  { return this.http.get<Patient>(`${this.apiUrl}/${id}`); }
  create(p: Patient)   { return this.http.post<Patient>(this.apiUrl, p); }
  update(id: string, p: Patient) { return this.http.put<Patient>(`${this.apiUrl}/${id}`, p); }
  delete(id: string)   { return this.http.delete(`${this.apiUrl}/${id}`); }
}

```

**Interceptors** son middleware del ciclo HTTP. Interceptan todas las requests y responses. El caso más común es adjuntar el token JWT en cada request automáticamente.

```typescript
export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const token = inject(AuthService).getToken();
  const authReq = req.clone({
    headers: req.headers.set('Authorization', `Bearer ${token}`)
  });
  return next(authReq);
};

```

Para el manejo de errores HTTP lo ideal es usar el operador `catchError` de RxJS, ya sea en el servicio o en un interceptor global.

```typescript
getAll() {
  return this.http.get<Patient[]>(this.apiUrl).pipe(
    catchError(err => {
      console.error('Error al obtener pacientes', err);
      return throwError(() => err);
    })
  );
}

```

----------

## Fase 3 — Angular Avanzado

### Signals

Los **Signals** son el nuevo sistema de reactividad de Angular, introducido en la versión 16 y maduro desde la 17. Un Signal es un valor reactivo: cuando cambia notifica asi, Angular sabe exactamente qué partes del template necesitan actualizarse, sin necesidad de revisar todo el árbol de componentes. Esto hace las apps más eficientes y el código más predecible.

```typescript
// signal básico
count = signal(0);
increment() { this.count.update(v => v + 1); }

// computed — se recalcula automáticamente cuando count cambia
double = computed(() => this.count() * 2);

// effect — ejecuta código cuando un signal cambia
constructor() {
  effect(() => console.log('count cambió a:', this.count()));
}

```

**`input()` y `output()`** son la versión signal de `@Input()` y `@Output()`. Son los recomendados en Angular 21.

```typescript
// hijo
name = input.required<string>();
saved = output<User>();

// en el template del hijo: {{ name() }}

```

**`toSignal()`** convierte un Observable en Signal. Muy útil para integrar HttpClient (que retorna Observables) con el nuevo sistema de Signals.

```typescript
patients = toSignal(this.patientService.getAll(), { initialValue: [] });
// en template: @for (p of patients(); track p.id)

```

**`resource()`** (Angular 19+) maneja carga asíncrona de datos de forma integrada con Signals. Tiene estados de `loading`, `value` y `error` automáticos.

```typescript
patientResource = resource({
  request: () => ({ id: this.patientId() }),
  loader: ({ request }) => this.service.getById(request.id)
});
// patientResource.value()      → el dato
// patientResource.isLoading()  → boolean

```

----------

### RxJS

**RxJS** en Angular es la librería que permite trabajar con flujos de datos asíncronos usando observables. Angular la usa internamente y la expone para manejar flujos de datos asíncronos como respuestas HTTP, eventos del usuario o WebSockets. Aunque Signals está tomando protagonismo, RxJS sigue siendo esencial para flujos complejos.

Un **Observable** es una fuente de datos que emite valores a lo largo del tiempo. Un **Subject** es un Observable al que también puedes emitirle valores externamente. Un **BehaviorSubject** es un Subject que recuerda su último valor y lo emite inmediatamente a cualquier nuevo suscriptor.

```typescript
// patrón común para estado en un servicio
private patients$ = new BehaviorSubject<Patient[]>([]);
patients = this.patients$.asObservable(); // expuesto como readonly

loadPatients() {
  this.http.get<Patient[]>('/api/patients').subscribe(data => {
    this.patients$.next(data);
  });
}

```
**Patron Observer**
-   Es un patrón de diseño que describe la relación **Observable → Observer**.
    
-   **Observable (sujeto)**: el que emite valores o eventos.
    
-   **Observer (observador)**: el que se suscribe y reacciona a esos valores.
    
-   La idea es que cuando el sujeto cambia o emite algo, todos los observadores suscritos reciben la notificación automáticamente.

Se usa principalmente cuando necesitas compartir datos en tiempo real entre componentes que no tienen una relación directa de padre a hijo (donde usarías `@Input` o `@Output`).


**Operators**

son funciones que permiten transformar y manipular flujos de datos emitidos por los  **Observables**, RxJS proporciona una amplia variedad de operadores que facilitan la manipulación y el control del flujo de datos en aplicaciones asíncronas, como las que se encuentran en Angular.

-   **Operadores de transformación**:  `map()`,  `pluck()`,  `mergeMap()`,  `switchMap()`,  `concatMap()`
-   **Operadores de filtrado**:  `filter()`,  `take()`,  `takeUntil()`,  `skip()`
-   **Operadores de combinación**:  `combineLatest()`,  `forkJoin()`,  `merge()`,  `zip()`
-   **Operadores de manejo de errores**:  `catchError()`,  `retry()`,  `retryWhen()`
-   **Operadores de temporización**:  `debounceTime()`,  `delay()`,  `throttleTime()`
-   **Operadores de creación**:  `fromEvent()`,  `interval()`,  `timer()`

----------

### Change Detection

La **detección de cambios** es el proceso por el que Angular verifica si el estado de la app cambió y actualiza el DOM en consecuencia.

**Estrategia Default** — Angular revisa todos los componentes del árbol en cada evento asíncrono (click, HTTP response, timer, etc). Funciona siempre pero puede ser lento en apps grandes.

**Estrategia OnPush** — Angular solo verifica el componente cuando: cambia un `@Input()` por referencia, el componente emite un evento, o se llama manualmente a `markForCheck()`. Es mucho más eficiente y es la estrategia recomendada junto con Signals.

```typescript
@Component({
  changeDetection: ChangeDetectionStrategy.OnPush,
  ...
})

```

**Zoneless (Angular 19+)** — Elimina Zone.js completamente. Angular solo actualiza el DOM cuando un Signal cambia. Es el futuro del framework. OnPush será el default en Angular 22.

----------

### Performance

**`@defer`** divide el template en chunks que se cargan solo cuando se necesitan. Es la herramienta más poderosa para reducir el tiempo de carga inicial.

```html
@defer (on idle) {
  <app-analytics-dashboard />
} @loading { <span>Cargando...</span> }
@placeholder { <div class="skeleton"></div> }

```

**`track` en `@for`** — Cuando la lista cambia, Angular usa el `track` para saber qué items son nuevos, cuáles se movieron y cuáles se eliminaron, en lugar de re-renderizar todo. Siempre usa el ID único del item.

**Lazy loading de rutas** — Divide el bundle de la app en chunks por ruta. El usuario solo descarga el código de lo que realmente visita.

**`NgOptimizedImage`** — Directiva para imágenes que agrega automáticamente `loading="lazy"`, define dimensiones para evitar layout shifts y prioriza la imagen del LCP.

```html
<img ngSrc="hero.jpg" width="800" height="400" priority />

```

----------

### Arquitectura de aplicaciones

**Smart vs Dumb components** — Los componentes "smart" (containers) tienen acceso a servicios y manejan el estado. Los componentes "dumb" (presentacionales) solo reciben datos por `@Input()` y emiten eventos por `@Output()`. Son más fáciles de testear y reutilizar.

**Facade pattern** — Un servicio que actúa como intermediario entre los componentes y la complejidad del estado (NgRx, múltiples servicios). El componente solo habla con el Facade y no sabe nada de lo que hay detrás.

**Estructura de carpetas por feature** — Agrupar todo lo relacionado a un dominio en una carpeta: componentes, servicios, modelos, rutas. Escala mejor que agrupar por tipo técnico.

```
src/
├── app/
│   ├── features/
│   │   ├── appointments/
│   │   │   ├── components/
│   │   │   ├── services/
│   │   │   ├── models/
│   │   │   └── appointments.routes.ts
│   │   ├── patients/
│   │   └── doctors/
│   ├── shared/
│   │   ├── components/
│   │   └── pipes/
│   └── core/
│       ├── interceptors/
│       └── guards/

```

**Barrel exports (`index.ts`)** — Archivo en cada carpeta que reexporta todo lo público. Simplifica los imports en el resto de la app.

----------

## Fase 4 — Ecosistema y Herramientas

### Testing

**Testing unitario** verifica que una clase o componente funcione correctamente de forma aislada. En Angular se usa `TestBed` para configurar un módulo de prueba mínimo.

```typescript
describe('PatientService', () => {
  let service: PatientService;
  let httpMock: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [provideHttpClientTesting()]
    });
    service = TestBed.inject(PatientService);
    httpMock = TestBed.inject(HttpTestingController);
  });

  it('debe obtener pacientes', () => {
    service.getAll().subscribe(patients => {
      expect(patients.length).toBe(2);
    });
    const req = httpMock.expectOne('/api/patients');
    req.flush([{ id: '1' }, { id: '2' }]);
  });
});

```

**`ComponentFixture`** es el wrapper que te da acceso al componente, a su DOM (`fixture.nativeElement`) y a la detección de cambios (`fixture.detectChanges()`).

**Jest** es la alternativa moderna a Karma + Jasmine. Es más rápido, no necesita browser real para correr y tiene una API muy similar. La mayoría de proyectos nuevos lo prefieren.

**Cypress / Playwright** son para testing End-to-End: simulan un usuario real interactuando con la app en un browser. Se usan para probar flujos completos como registro, login, hacer una cita, etc.

----------

### Estado global

El manejo de estado global responde a la pregunta: ¿cómo comparten datos componentes que no tienen relación padre-hijo?

**Servicios + BehaviorSubject** — La solución más simple. Un servicio guarda el estado en un `BehaviorSubject` y los componentes se suscriben. Suficiente para la mayoría de apps medianas.

**NgRx Store** — Implementación de Redux para Angular. El estado es inmutable y solo cambia mediante Actions. Es predecible y facilita el debugging con Redux DevTools, pero tiene bastante boilerplate. Recomendado para apps grandes con estado complejo.

```
Usuario hace click → dispatch(Action) → Reducer crea nuevo estado → Selector → Componente se actualiza

```

**NgRx Signals Store** — La versión moderna de NgRx, basada en Signals. Mucho menos boilerplate que el Store clásico y totalmente integrado con el nuevo modelo reactivo de Angular.

```typescript
export const PatientsStore = signalStore(
  withState({ patients: [] as Patient[], isLoading: false }),
  withMethods((store) => ({
    loadPatients: rxMethod<void>(pipe(
      switchMap(() => inject(PatientService).getAll()),
      tapResponse(patients => patchState(store, { patients }), console.error)
    ))
  }))
);

```

----------

### Seguridad

**JWT + Interceptor** — El patrón estándar para autenticación en SPAs. El interceptor adjunta el token en cada request, y si el servidor retorna 401, puede intentar renovarlo automáticamente.

**`DomSanitizer`** — Angular sanitiza automáticamente el HTML en el template para prevenir XSS. Solo necesitas usar `DomSanitizer` cuando quieres insertar HTML dinámico con `[innerHTML]` y confías en la fuente.

**`angular-oauth2-oidc`** — Librería que implementa el flujo OAuth2/OIDC (con PKCE) para autenticación con proveedores externos como Google, Keycloak o Auth0. Maneja tokens, refresh y logout automáticamente.

**CSRF** — HttpClient tiene soporte automático: lee el cookie `XSRF-TOKEN` y lo envía como header `X-XSRF-TOKEN` en cada request mutante (POST, PUT, DELETE). Solo necesitas que el backend lo genere.

----------

### ESLint y calidad de código

**`@angular-eslint`** — Conjunto de reglas ESLint específicas para Angular que detectan malos patrones como usar `any`, no usar `trackBy`, o tener subscriptions sin cerrar.

**`Prettier`** — Formateador automático de código. Elimina las discusiones de estilo en el equipo: todo el código se ve igual independientemente de quién lo escribió.

**`Husky` + `lint-staged`** — Pre-commit hooks que ejecutan el linter y el formateador automáticamente antes de cada commit. Impide subir código con errores al repositorio.

----------

## Fase 5 — Nivel Profesional

### SSR — Server-Side Rendering

**SSR** significa que el servidor genera el HTML completo de la página antes de enviarlo al browser, en lugar de enviar un HTML vacío y construirlo todo con JavaScript en el cliente. Esto mejora el SEO (los crawlers ven el contenido real) y el tiempo de primera pintada (FCP).

En Angular se activa con `@angular/ssr` y `provideServerRendering()`.

**Hydration** — Tras recibir el HTML del servidor, Angular lo "hidrata": conecta los event listeners y hace el DOM interactivo sin volver a renderizarlo desde cero. Desde Angular 17+ la hydration está habilitada por defecto.

**`TransferState`** — Mecanismo que evita hacer la misma llamada HTTP dos veces (una en el servidor y otra en el browser). El servidor serializa los datos en el HTML y el cliente los lee directamente.

----------

### CI/CD y Deploy

**Build de producción** — `ng build --configuration=production` activa optimizaciones automáticas: AOT compilation, minificación, tree-shaking y hashing de archivos (el nombre incluye un hash para invalidar caché).

**Docker + Nginx** — El patrón más común para deployar Angular: una imagen multi-stage donde el primer stage hace el build y el segundo stage es Nginx sirviendo los archivos estáticos.

```dockerfile
FROM node:20 AS builder
WORKDIR /app
COPY . .
RUN npm ci && ng build --configuration=production

FROM nginx:alpine
COPY --from=builder /app/dist/my-app/browser /usr/share/nginx/html

```

**`APP_INITIALIZER`** — Token que ejecuta código asíncrono antes de que la app arranque. Se usa para cargar configuración dinámica desde el servidor (feature flags, URL del backend) antes de renderizar nada.

```typescript
providers: [{
  provide: APP_INITIALIZER,
  useFactory: (config: ConfigService) => () => config.load(),
  deps: [ConfigService],
  multi: true
}]

```

----------

## Referencia rápida — Decoradores y funciones clave

Elemento

Para qué sirve

`@Component`

Define un componente (template + lógica + estilos)

`@Directive`

Define una directiva sin template propio

`@Pipe`

Define un transformador de datos para el template

`@Injectable`

Marca una clase como servicio inyectable

`@Input()` / `input()`

El padre le pasa un dato al hijo

`@Output()` / `output()`

El hijo le comunica un evento al padre

`@ViewChild`

Accede a un elemento del propio template desde TS

`@HostListener`

Escucha un evento del elemento host de la directiva

`@HostBinding`

Enlaza una propiedad del host de la directiva

`inject()`

Inyecta una dependencia (forma moderna, sin constructor)

`signal()`

Crea un valor reactivo

`computed()`

Signal derivado que se recalcula automáticamente

`effect()`

Ejecuta código como side effect cuando un signal cambia

`toSignal()`

Convierte un Observable en Signal

`toObservable()`

Convierte un Signal en Observable

`resource()`

Carga asíncrona de datos integrada con Signals

----------
