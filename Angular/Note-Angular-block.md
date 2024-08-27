# Angular

### @NgModule

NgModule es esencial para estructurar aplicaciones Angular. Organiza los componentes, servicios y otros módulos en unidades cohesivas, facilitando la gestión y el mantenimiento. Entender cómo y cuándo usar módulos es fundamental para desarrollar aplicaciones Angular de manera efectiva.

- **declarations**: Aquí se definen los componentes, directivas y pipes que pertenecen a este módulo.
  Si tienes un componente UserComponent, lo declararías aquí.

- **imports** : Aquí se importan otros módulos que el módulo actual necesita. Para usar directivas de    formularios, puedes importar FormsModule o ReactiveFormsModule.

- **exports** : Aquí se especifican los componentes, directivas y pipes que se deben hacer disponibles   para otros módulos que importen este módulo.  Si quieres que UserComponent esté disponible en   otros módulos, lo exportarías aquí.

- **providers**: Aquí se configuran los servicios que el módulo necesita. Esto incluye servicios que   deberían estar disponibles en toda la aplicación o solo para el módulo específico. Si tienes un   servicio UserService, lo declararías aquí para que esté disponible para los componentes de este     módulo.

### COMPONENTES y CICLO DE VIDA

**Componentes**:  Encapsulando la lógica y la presentación de la interfaz de usuario.

**Ciclo de vida**: En Angular, el ciclo de vida de los componentes se refiere a las fases por las que pasa un  componente desde que se crea hasta que se destruye.

- **ngOnChanges** : Se llama cuando se cambian las propiedades de entrada (@Input()) del  componente. Utiliza este hook para reaccionar a cambios en las entradas del componente. 

-  **ngOnInit** :  Se llama una vez que el componente ha sido inicializado completamente. Es el lugar  adecuado para inicializar propiedades del componente y hacer solicitudes HTTP.  Utiliza este hook  para ejecutar lógica de inicialización que necesita ser realizada solo una vez.

-  **ngDoCheck**: Se llama durante cada ciclo de detección de cambios. Permite una verificación adicional y personalizada. Utiliza este hook para implementar lógica de detección de cambios personalizada que no se cubra con ngOnChanges.

-  **ngOnDestroy**: Se llama justo antes de que el componente sea destruido. Es útil para limpiar recursos y cancelar suscripciones. Utiliza este hook para liberar recursos, cancelar suscripciones y limpiar el componente antes de que se elimine.

Ejemplo: Si tienes un componente HomeComponent y navegas a AboutComponent, el HomeComponent se destruye y el AboutComponent se crea. Angular llama al hook ngOnDestroy del componente antes de que se complete su destrucción. Este hook es el lugar adecuado para realizar tareas de limpieza, como cancelar suscripciones, liberar recursos y limpiar temporizadores.

### Templates y Estilo

- **Interpolación**: Permite insertar valores de propiedades del componente en el template.
```typescript
export class AppComponent {
  title = 'Mi Aplicación Angular';
  }

  <!-- app.component.html -->
  <h1>{{ title }}</h1>

```

- **Directivas de atributo**: Como ngClass y ngStyle, que permiten aplicar estilos o clases  dinámicamente.
```typescript
export class AppComponent { 
isActive = true;
 }
```
```typescript
<div [ngClass]="{ 'active': isActive, 'inactive': !isActive }">
 This is a test div. 
 </div>
```

```typescript
<div [ngStyle]="{ 'color': isActive ? 'green' : 'red', 'font-size': '20px' }">
 This is a test div. 
 </div>
```

### Data Binding 

 Data Binding en Angular permite sincronizar los datos entre el componente y la vista. Existen tres tipos principales:
 
- Property Binding: Se utiliza para enlazar una propiedad del componente a un atributo HTML. Se usa la sintaxis [attribute]="expression".

```typescript
   // app.component.ts
   export class AppComponent {
    imageUrl = 'https://example.com/image.jpg';
  }

  <img [src]="imageUrl" alt="Example Image">
  ```
  ```typescript
  
<div [class.active]="isActive">
  Contenido
</div>

<div [class]="textoColor"> Contenido </div>
  ```

- Event Binding : Se utiliza para manejar eventos del usuario, como clics, cambios, etc. Se usa la sintaxis (event)="handler".

```typescript
  // app.component.ts
   export class AppComponent {
   onClick() {
    alert('Button clicked!');
   }
  }
  
  <!-- app.component.html -->
<button (click)="onClick()">Click Me</button>

```
- Two-Way Binding: Permite la sincronización bidireccional entre una propiedad del componente y un elemento del DOM. Se usa la sintaxis [(ngModel)]="property".
```typescript
     export class AppComponent {
     name = '';
     }

<!-- app.component.html -->
<input [(ngModel)]="name" placeholder="Enter your name">
<p>Hello, {{ name }}!</p>
```

### Comunicación (Input - Output) 
Permite que un componente padre pase datos al componente hijo y que el componente hijo emita eventos que el padre puede manejar.

Métodos:

- @Input(): Para pasar datos del componente padre al componente hijo.

- @Output(): Para enviar eventos desde el componente hijo al componente padre.

```typescript
 <h1>componente Padre </h1>

<input type="text" class="form-control" [(ngModel)]="title" placeholder="input component padre">

<app-comunica [varPadre]="title" (titleKey)="title = $event "></app-comunica> 
```
```typescript
export class ComunicaComponent {
 
    @Input() varPadre?:string;

     //evento personalizado
     @Output() titleKey = new EventEmitter<string>();

    evetTecla(){
       console.log("evento cambiado");
       //quiero ejecutar el ev personalizado
       this.titleKey.emit(this.varPadre);
    }
}

```

### SERVICIOS 

Un servicio en Angular es una clase que está diseñada para proporcionar funcionalidades que pueden ser compartidas a lo largo de diferentes componentes y otras partes de la aplicación. Los servicios son una forma de organizar y estructurar la lógica de negocio y de acceso a datos de manera modular y reutilizable.


```typescript
@Injectable({
  providedIn: 'root'
})
export class DataService {
  private apiUrl = 'https://api.example.com/data';

  constructor(private http: HttpClient) { }

  getData(): Observable<any> {
    return this.http.get<any>(this.apiUrl);
  }
}

 constructor(private dataService: DataService) { }

  ngOnInit(): void {
    this.dataService.getData().subscribe(response => {
      this.data = response;
    });
  }

```

-  **Interceptors**: Los interceptores permiten modificar las solicitudes y respuestas HTTP  globalmente. Puedes usarlos para agregar encabezados, manejar errores globalmente, o hacer  otros ajustes:

### Directivas  

Una directiva es una clase con un decorador que permite manipular el DOM (Document Object Model) y alterar la apariencia o el comportamiento de los elementos HTML. Las directivas permiten agregar comportamiento a los elementos de la vista y se pueden clasificar en tres tipos principales:

> Decorador: @Component,  Se usa para crear una nueva vista con HTML y lógica asociada.

> Directivas Estructurales: Estas directivas alteran el diseño del DOM al agregar o eliminar elementos   HTML. Utilizan un asterisco (*) en la plantilla. *ngIf, *ngFor

> Directivas de Atributo : Estas directivas alteran la apariencia o el comportamiento de un elemento   DOM existente. No cambian la estructura del DOM, sino que modifican el comportamiento o el estilo de   los elementos. [ngClass],  [ngStyle]

### PIPES   
Los pipes (o "tuberías") son una característica que permite transformar datos en plantillas. Los pipes toman un valor de entrada, lo transforman de alguna manera, y luego muestran el valor transformado en la vista. Son útiles para formatear datos de manera simple y concisa.

1) Pipes Incorporados: ofrece varios pipes incorporados para realizar transformaciones comunes  de datos. 

```typescript
- {{ fecha | date:'shortDate' }}
- {{ cantidad | currency:'USD':'symbol':'1.2-2' }}
- {{ numero | number:'1.0-2' }}
- {{ objeto | json }}

```


2) Pipes Personalizados: Puedes crear tus propios pipes para realizar transformaciones específicas que no están cubiertas por los pipes incorporados. 
 
-  ng generate pipe nombre


### Enrutamiento 
Permite a los usuarios cambiar de una vista a otra sin recargar la página completa.
```typescript

const routes: Routes = [
  { path: '', component: HomeComponent },
  { path: 'about', component: AboutComponent },
  { path: '**', component: NotFoundComponent }  
];


```

1) **RouterOutlet**: Es donde se renderizarán los componentes basados en la ruta activa.

```typescript
<nav>
  <a routerLink="/">Home</a>
  <a routerLink="/about">About</a>
</nav>

<router-outlet></router-outlet>

```
2) **Parámetros de Ruta**: Las rutas pueden contener parámetros que se usan para pasar información a los componentes.

```typescript
// Navegar a una ruta que recibe parametro.

!-- HTML -->
<a [routerLink]="['/user', Id]">Actualizar</a>

```
```typescript
// recuperar parametro


this.route.paramMap.subscribe(params => {
  const idProd = params.get('idProd');
  console.log(idProd); // Accede al parámetro de forma segura
});

```

### Estructuras de Control

- Permiten manejar la lógica en las plantillas (HTML) y en el código TypeScript de los  componentes.

- *ngIf se usa para mostrar u ocultar elementos del DOM basado en una condición.

- *ngFor se usa para iterar sobre una colección y crear una instancia del elemento para cada    ítem en la colección.

- *ngSwitch se usa para mostrar un solo elemento entre varios posibles basados en una   expresión.

### Formulario 

1) **FORMULARIO REACTIVO**: Permite manejar el estado del formulario y la validación de manera programática.

```typescript
export class FormularioReactivoComponent implements OnInit {
  formulario: FormGroup;

  constructor(private fb: FormBuilder) {}

  ngOnInit(): void {
    this.formulario = this.fb.group({
      nombre: ['', Validators.required],
      email: ['', [Validators.required, Validators.email]],
      edad: ['', [Validators.required, Validators.min(18)]]
    });
  }

  onSubmit() {
    if (this.formulario.valid) {
      console.log(this.formulario.value);
    }
  }
}

// HTML

<form [formGroup]="formulario" (ngSubmit)="onSubmit()">
  <div>
    <label for="nombre">Nombre:</label>
    <input id="nombre" formControlName="nombre" />
    <div *ngIf="formulario.get('nombre').invalid && formulario.get('nombre').touched">
      Nombre es requerido.
    </div>
  </div>

  <div>
    <label for="email">Email:</label>
    <input id="email" formControlName="email" />
    <div *ngIf="formulario.get('email').invalid && formulario.get('email').touched">
      Email es inválido.
    </div>
  </div>

  <button type="submit" [disabled]="formulario.invalid">Enviar</button>
</form>

```

2) **FORMULARIO BASADO PLANTILLA**: Están basados en el uso de ngModel para vincular datos y manejar validaciones.

```typescript
export class FormularioTemplateComponent {
  // Propiedades para enlazar con el formulario
  nombre: string = '';

  // Método para manejar el envío del formulario
  onSubmit(form: any) {
    if (form.valid) {
      console.log('Formulario enviado', {
        nombre: this.nombre,
        email: this.email
      });
    } else {
      console.log('Formulario no válido');
    }
  }
}

//HTML 

<form #form="ngForm" (ngSubmit)="onSubmit(form)">
  <div>
    <label for="nombre">Nombre:</label>
    <input id="nombre"  name="nombre" [(ngModel)]="nombre" required 
    #nombreModel="ngModel"/>
    <div *ngIf="nombreModel.invalid && nombreModel.touched">
      Nombre es requerido.
    </div>
  </div>

  <button type="submit" [disabled]="form.invalid">Enviar</button>
</form>


```



