# Novedades

# Angular - 16

### SIGNALS
- Cuando hablamos de "reactivo" en el contexto de la programación, nos referimos a un enfoque donde el sistema o el código reacciona automáticamente a cambios en el estado o en los datos, sin necesidad de intervención manual para actualizar la UI o realizar cálculos. 

- Código Reactivo: El código con Signals es considerado reactivo porque la actualización de result ocurre automáticamente en respuesta a los cambios en num1 y num2, sin intervención manual.

- Código No Reactivo: El código sin Signals requiere un manejo explícito de las actualizaciones, por lo que no se considera reactivo en el mismo sentido.

> **Con Signals**

Gracias a la reactividad de los Signals, cada vez que presionas uno de los botones para incrementar num1 o num2, result se recalcula y la UI se actualiza automáticamente.
```typescript
@Component({
  selector: 'app-sum',
  template: `
    <div>
      <p>Número 1: {{ num1() }}</p>
      <p>Número 2: {{ num2() }}</p>
      <p>Resultado: {{ result() }}</p>
      <button (click)="incrementNum1()">Incrementar Número 1</button>
      <button (click)="incrementNum2()">Incrementar Número 2</button>
    </div>
  `,
})
export class SumComponent {
  // Signals para los números y el resultado
  num1 = signal(0);
  num2 = signal(0);

  // Signal calculado para el resultado
  result = computed(() => this.num1() + this.num2());

  // Métodos para incrementar los números
  incrementNum1() {
    this.num1.update(value => value + 1);
  }

  incrementNum2() {
    this.num2.update(value => value + 1);
  }
}

```

> **SIN Signals**

En este enfoque, debes llamar explícitamente al método calculateSum() después de cambiar num1 o num2 para asegurarte de que result se actualice correctamente. Este es un enfoque tradicional que sigue siendo muy común en Angular, pero carece de la reactividad automática que ofrece el uso de Signals.

```typescript
@Component({
  selector: 'app-sum',
  template: `
    <div>
      <p>Número 1: {{ num1 }}</p>
      <p>Número 2: {{ num2 }}</p>
      <p>Resultado: {{ result }}</p>
      <button (click)="incrementNum1()">Incrementar Número 1</button>
      <button (click)="incrementNum2()">Incrementar Número 2</button>
    </div>
  `,
})
export class SumComponent {
  // Propiedades para los números y el resultado
  num1: number = 0;
  num2: number = 0;
  result: number = 0;

  // Método para incrementar num1
  incrementNum1() {
    this.num1 += 1;
    this.calculateSum();
  }

  // Método para incrementar num2
  incrementNum2() {
    this.num2 += 1;
    this.calculateSum();
  }

  // Método para calcular la suma
  calculateSum() {
    this.result = this.num1 + this.num2;
  }
}

```


### STAND ALONE

Antes de que se introdujeran los componentes standalone, Angular organizaba aplicaciones en módulos. Estos módulos (NgModule) servían como contenedores para agrupar componentes, directivas, pipes, y servicios. Cualquier componente, directiva o pipe que quisieras utilizar en tu aplicación debía estar declarado dentro de un módulo.

- Overhead y complejidad: Cada vez que creabas un nuevo componente, tenías que declararlo en un módulo, lo que incrementaba la cantidad de archivos y la complejidad en aplicaciones grandes.

- Modularidad: Para usar un componente en otro módulo, tenías que exportarlo en su módulo original e importarlo en el nuevo módulo.



Angular introdujo los componentes standalone para simplificar la creación y el uso de componentes, permitiéndoles ser independientes de los módulos. Un componente standalone no necesita ser declarado en ningún módulo; en lugar de eso, puede importar directamente los módulos y servicios que necesita.

```typescript
@Component({
  selector: 'app-my-standalone-component',
  standalone: true, // Indica que este componente es standalone
  imports: [CommonModule, FormsModule], // Importas lo que necesites
  template: `<p>¡Hola desde el componente standalone!</p>`,
})
export class MyStandaloneComponent {}


// No necesitas un módulo adicional, simplemente lo importas directamente donde lo necesites.

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [MyStandaloneComponent],
  template: `
    <h1>Componente raíz</h1>
    <app-my-standalone-component></app-my-standalone-component>
  `,
})
export class AppComponent {}
```

### INJECTION 


- Nueva forma de inyectar dependencias sin necesidad de un constructor.

> Inyectamos el servicio a través del constructor - Antes
```typescript
  constructor(private counterService: CounterService) {
    this.counter = this.counterService.getCounter();
  }
```

> Ahora
```typescript
 private counterService = inject(CounterService); // Inyectamos usando inject()

 constructor() {
    this.counter = this.counterService.getCounter();
  }
```

### INPUT (Required)

- Nueva validacion para que los intercambios de informacion entre componentes 
  sean mas seguros y eficientes.
  
```typescript
// ANTES

@Input() varPadre?:string;

//AHORA

@Input({required:true}) varPadre?:string;

```

### Ng OnDestroy

# Angular - 17

### Sintaxis Estructura de Control
Angular 17 introduce una nueva sintaxis de control de flujo que mejora cómo se manejan las estructuras condicionales y repetitivas dentro de las plantillas. Esta sintaxis simplifica el uso de declaraciones como if, switch, y for sin necesidad de los atributos estructurales tradicionales como *ngIf, *ngSwitch, y *ngFor.

```typescript
//Antes

<div *ngIf="userStatus === 'active'; else inactiveBlock">
  <p>El usuario está activo.</p>
</div>

<ng-template #inactiveBlock>
  <div *ngIf="userStatus === 'inactive'; else pendingBlock">
    <p>El usuario está inactivo.</p>
  </div>
</ng-template>

<ng-template #pendingBlock>
  <div *ngIf="userStatus === 'pending'; else unknownBlock">
    <p>El usuario está pendiente de activación.</p>
  </div>
</ng-template>

<ng-template #unknownBlock>
  <p>Estado del usuario desconocido.</p>
</ng-template>

// Ahora

@if (userStatus === 'active') {
  <p>El usuario está activo.</p>
} @else if (userStatus === 'inactive') {
  <p>El usuario está inactivo.</p>
} @else if (userStatus === 'pending') {
  <p>El usuario está pendiente de activación.</p>
} @else {
  <p>Estado del usuario desconocido.</p>
}

```


### Vistas Aplazables
```typescript
//Antes
ViewContainerRef se usa cuando quieres insertar o quitar componentes 
de tu aplicación de forma dinámica, es decir, durante la ejecución 
del programa y no solo cuando se carga la página. Esto es útil
cuando necesitas mostrar diferentes componentes en función de la
interacción del usuario o ciertos eventos.


//Ahora 

@defer {
   <Component />
}  
```


### Renderizado Hibrido

> Para habilitar SSR en nuevos proyectos

- ng new my-proyecto -ssr


### STANDALONE AL COMIENZO

> Para iniciar el proyecto con StandAlone por defecto

- ng generate @angular/core:standalone



