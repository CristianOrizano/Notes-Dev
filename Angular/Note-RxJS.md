# RX JS - ANGULAR

### OBSERVABLES
Un **Observable** es un **patrón de diseño** basado en la idea de que un objeto puede emitir valores, y otros objetos pueden suscribirse para recibirlos.

Es similar a una **Promesa**, pero con diferencias clave:  
✅ Un **Observable** puede emitir **múltiples valores** en diferentes momentos.  
✅ Un **Observable** se puede **cancelar** (`unsubscribe()`), mientras que una Promesa no.  
✅ Los Observables pueden trabajar con **operadores** (`map`, `filter`, `mergeMap`, etc.), lo que facilita la manipulación de datos.
✅Los Observables **no se ejecutan hasta que alguien se suscribe a ellos**.

```typescript
//service
export class HomeService {
  constructor() { }
  obtenerDatos(): Observable<string> {
    return new Observable(observer => {
      observer.next('Primer dato');
      observer.next('Segundo dato');
      observer.complete();
    });
  }
}

//component.ts
export class HomeComponent  implements OnInit{
  mensaje: string = '';
  constructor(private dataService: HomeService) {}
  ngOnInit() {
    this.dataService.obtenerDatos().subscribe({
      next: (valor) => {
        this.mensaje = valor,
        console.log(valor)
      },
      complete: () => console.log('¡Flujo completado!')
    });
  }
}
```
**Un Observable tiene tres posibles estados:**

1️⃣ **next(value)** → Emite un valor a los suscriptores.  
2️⃣ **error(err)** → Finaliza el flujo debido a un error.  
3️⃣ **complete()** → Finaliza el flujo sin errores.
```typescript
const observable = new Observable(observer => {
  observer.next('Valor 1');
  observer.next('Valor 2');
  
  // Emitiendo un error
  observer.error('Ocurrió un error');

  observer.next('Valor 3'); // Nunca se ejecutará
});
```

-  Puedes crear observables sin necesidad de `new Observable()` , con métodos como of, from, interval,     fromEvent.
- 
   - **of()** → Emite valores secuenciales
   - **from()** → Convierte un array, Promesa o iterable en un Observable 
   - **interval()** → Genera un flujo de valores cada cierto tiempo
   - **timer()** → Inicia después de un tiempo específico

 **Es **unidireccional**, solo emite valores:**

```typescript
@Injectable({
  providedIn: 'root'
})
export class DataService {
  obtenerDatos(): Observable<number> {
    return new Observable(observer => {
      setInterval(() => observer.next(Math.random()), 1000);
    });
  }
}
//component.ts
export class AppComponent implements OnInit {
  constructor(private dataService: DataService) {}

  ngOnInit() {
    this.dataService.obtenerDatos().subscribe(valor => console.log('Suscriptor 1:', valor));
    this.dataService.obtenerDatos().subscribe(valor => console.log('Suscriptor 2:', valor));
  }
}

//>>salida
//Cada suscriptor recibe un valor diferente porque el Observable
//se ejecuta de manera independiente para cada suscriptor.
Suscriptor 1: 0.8453
Suscriptor 2: 0.6252
```




### Subjects en RxJS

Los **Subjects** en RxJS son un tipo especial de **Observable** que permite tanto **emitir datos** como **escuchar** valores emitidos. Se usan cuando múltiples suscriptores necesitan compartir el mismo flujo de datos.

✅ Es **bidireccional**, puede **emitir y recibir** datos.
✅ Todos los suscriptores comparten el **mismo flujo** de datos.
✅ Se crea con `new Subject()`.


```typescript
@Injectable({
  providedIn: 'root'
})
export class HomeService {
  //Subject
  private dataSubject = new Subject<number>();
  datos$ = this.dataSubject.asObservable();

  emitirValor(valor: number): void {
    this.dataSubject.next(valor);
  }
}

//component.ts
export class HomeComponent{
  ngOnInit() {
  this.subscription = this.dataService.datos$.subscribe((valor) => {
      console.log('Valor recibido Suscriptor 1:', valor);
    });
    this.subscription = this.dataService.datos$.subscribe((valor) => {
      console.log('Valor recibido Suscriptor 2:', valor);
    });
}
 emitirValor(): void {
    const valorAleatorio = Math.random();
    this.dataService.emitirValor(valorAleatorio);
  }
}

>>>>> SALIDA
//Aquí, ambos suscriptores reciben el mismo valor, 
//porque `Subject` comparte el flujo.

Suscriptor 1: 0.7625 
Suscriptor 2: 0.7625
```
#### Tipos de Subjects

**BehaviorSubject**:

-   **Descripción**: Mantiene el último valor emitido y lo emite inmediatamente a cualquier nuevo suscriptor.
-   **Uso**: Ideal para representar estados que pueden cambiar con el tiempo y que los suscriptores necesitan conocer el estado actual al suscribirse.

```typescript
const behaviorSubject = new BehaviorSubject<number>(0); // Valor inicial 0

behaviorSubject.subscribe(valor => console.log('Suscriptor A:', valor));
behaviorSubject.next(1);
behaviorSubject.subscribe(valor => console.log('Suscriptor B:', valor));
behaviorSubject.next(2);
// Salida:
// Suscriptor A: 0
// Suscriptor A: 1
// Suscriptor B: 1
// Suscriptor A: 2
// Suscriptor B: 2
```

**ReplaySubject**:

-   **Descripción**:Un `ReplaySubject` recuerda un número determinado de valores emitidos y los reenvía a cualquier nuevo suscriptor.
-   **Uso**: Útil cuando necesitas que los nuevos suscriptores reciban todos los valores emitidos anteriormente.
```typescript

const replaySubject = new ReplaySubject<number>(2); // Buffer de tamaño 2

replaySubject.subscribe(valor => console.log('Suscriptor A:', valor));
replaySubject.next(1);
replaySubject.next(2);
replaySubject.next(3);
replaySubject.subscribe(valor => console.log('Suscriptor B:', valor));
replaySubject.next(4);
// Salida:
// Suscriptor A: 1
// Suscriptor A: 2
// Suscriptor A: 3
// Suscriptor B: 2
// Suscriptor B: 3
// Suscriptor A: 4
// Suscriptor B: 4
```

### Subscription
 Una suscripción es la acción de observar los valores emitidos por un  observable. Es importante manejar las suscripciones correctamente para evitar fugas de  memoria.
 
 **Suscribirse a un Observable:** 
 - const subscription = numbers$.subscribe(value => console.log(value));

 **Desuscribirse de un Observable:**
 - subscription.unsubscribe();
 
 
### Operators

son funciones que permiten transforman y manipular flujos de datos emitidos por los **Observables**, RxJS proporciona una amplia variedad de operadores que facilitan la manipulación y el control del flujo de datos en aplicaciones asíncronas, como las que se encuentran en Angular.

-   **Operadores de transformación**: `map()`, `pluck()`, `mergeMap()`, `switchMap()`, `concatMap()`
-   **Operadores de filtrado**: `filter()`, `take()`, `takeUntil()`, `skip()`
-   **Operadores de combinación**: `combineLatest()`, `forkJoin()`, `merge()`, `zip()`
-   **Operadores de manejo de errores**: `catchError()`, `retry()`, `retryWhen()`
-   **Operadores de temporización**: `debounceTime()`, `delay()`, `throttleTime()`
-   **Operadores de creación**: `fromEvent()`, `interval()`, `timer()`
