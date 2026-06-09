# MongoDB - Guía de Estudio

## 📌 Unidad 1: Introducción y Fundamentos de MongoDB

### 1.1 ¿Qué es MongoDB?
MongoDB es una base de datos NoSQL orientada a documentos, diseñada para almacenar grandes volúmenes de datos con alta disponibilidad, rendimiento óptimo y escalabilidad horizontal nativa.

#### 🔹 Ventajas y Desventajas
* **Ventajas:**
    * **Esquema Flexible (Schemaless):** No requiere definir tablas ni columnas de antemano. Cada documento puede mutar de forma independiente según las necesidades del negocio.
    * **Alto Rendimiento:** Almacena los datos relacionados juntos en memoria o disco mediante documentos embebidos, eliminando la necesidad de realizar operaciones costosas de unión (`JOIN`).
    * **Escalabilidad Horizontal:** Diseñado desde su origen para escalar a través de múltiples servidores mediante *Sharding* (particionamiento de datos) de manera nativa.
* **Desventajas:**
    * **Mayor consumo de memoria:** Al no aplicar una normalización estricta, suele duplicar datos intencionalmente para ganar velocidad, lo que incrementa el uso de almacenamiento y memoria RAM.
    * **Uso limitado de transacciones complejas:** Aunque las versiones modernas soportan transacciones ACID multi-documento, el motor no está óptimamente diseñado para sistemas donde la transaccionalidad pura y masiva sea el eje central (ej. contabilidad bancaria).

#### 🔹 Arquitectura y Estructura Jerárquica
A diferencia de los sistemas relacionales basados en tablas rígidas con filas y columnas, la jerarquía de almacenamiento en MongoDB se distribuye de la siguiente manera:



* **Base de Datos (Database):** El contenedor físico y lógico de nivel superior, equivalente a una base de datos en SQL.
* **Colección (Collection):** El equivalente directo a una **Tabla**. Es un agrupador lógico de documentos, pero no impone ninguna estructura ni restricción sobre los campos.
* **Documento (Document):** El equivalente a una **Fila** o registro. Es la unidad básica de información en MongoDB y se estructura y almacena internamente en formato **BSON**.

---

### 1.2 Entorno de Trabajo y Herramientas

#### 🔹 Herramientas Esenciales del Ecosistema
1. **MongoDB Community Server:** El motor principal de la base de datos que se ejecuta en segundo plano como un servicio del sistema operativo gestionando el almacenamiento y las peticiones.
2. **MongoDB Compass:** La interfaz gráfica de usuario (GUI) oficial. Facilita la visualización de colecciones, inserción visual de datos, optimización de índices y la construcción interactiva de tuberías de agregación (*pipelines*).
3. **Mongosh (MongoDB Shell):** La terminal interactiva basada en JavaScript que permite ejecutar comandos de administración, consultas avanzadas y scripts directamente sobre el motor.

#### 🔹 Instalación y Configuración Base
* **Puerto Estándar:** Por defecto, el servicio de MongoDB escucha e interactúa a través del puerto **`27017`**.
* **Archivo de Configuración (`mongod.cfg`):** Archivo clave para configurar el comportamiento del motor. Sus directivas principales incluyen:
    * `dbPath`: Define la ruta del disco donde se guardarán físicamente los archivos de los datos.
    * `logPath`: Define la ubicación del archivo de registros y auditoría del sistema.
    * `bindIp`: IP de escucha. Por seguridad local inicial, viene configurado en `127.0.0.1` (localhost).

#### 🔹 Formato BSON y Tipos de Datos Principales
MongoDB lee JSON, pero almacena los datos en **BSON (Binary JSON)**. El formato BSON optimiza el espacio y la velocidad de búsqueda, añadiendo tipos de datos que el JSON convencional no soporta de forma nativa:

| Tipo de Dato BSON | Descripción | Ejemplo / Representación |
| :--- | :--- | :--- |
| **`ObjectId`** | ID único obligatorio de 12 bytes generado automáticamente por el motor para el campo `_id`. Contiene el timestamp exacto de creación. | `ObjectId("64b7f1a2c9e8d734567890ab")` |
| **`String`** | Cadena de texto estándar codificada en UTF-8. | `"Cristian Orizano"` |
| **`Integer / Double`** | Valores numéricos enteros (de 32 o 64 bits) o números de punto flotante para decimales. | `24` o `1250.50` |
| **`Boolean`** | Estado lógico binario. | `true` o `false` |
| **`Date`** | Fecha y hora almacenada internamente en formato de milisegundos Unix bajo la zona horaria UTC. | `ISODate("2026-06-09T21:42:00Z")` |
| **`Array`** | Listas indexadas de valores, objetos o subdocumentos. | `["developer", "analyst"]` |
| **`Object`** | Un documento completo embebido o incrustado dentro de un campo principal (*Subdocumento*). | `{ "calle": "Av. Central", "numero": 123 }` |
| **`Null`** | Representa la ausencia de valor o un campo vacío. | `null` |


## 📌 Unidad 2: CRUD

### 2.1 ¿Qué es CRUD?
Las 4 operaciones base sobre cualquier base de datos. En MongoDB se ejecutan sobre **colecciones**.

| CRUD | SQL equiv. | Métodos MongoDB |
|:---|:---|:---|
| Create | `INSERT` | `insertOne()`, `insertMany()` |
| Read | `SELECT` | `find()`, `findOne()` |
| Update | `UPDATE` | `updateOne()`, `updateMany()`, `replaceOne()` |
| Delete | `DELETE` | `deleteOne()`, `deleteMany()` |

---

### 2.2 CREATE
```js
db.clientes.insertOne({ nombre: "Cristian", edad: 24 });

db.productos.insertMany([
  { nombre: "Laptop", precio: 3500 },
  { nombre: "Mouse", precio: 80 }
], { ordered: false }); // si uno falla, continúa con los demás
```

---

### 2.3 READ
```js
db.clientes.find({ activo: true }, { nombre: 1, email: 1, _id: 0 }); // 2do arg = proyección
db.clientes.findOne({ email: "cris@valtx.pe" }); // retorna objeto, no cursor
```

---

### 2.4 UPDATE
Siempre requieren un **operador `$`** para indicar qué hacer con el campo.

```js
db.clientes.updateOne({ email: "cris@valtx.pe" }, { $set: { edad: 25 } });
db.productos.updateMany({ stock: { $lt: 10 } }, { $set: { estado: "BAJO_STOCK" } });
db.clientes.replaceOne({ _id: ... }, { nombre: "Cris", edad: 25 }); // reemplaza TODO (cuidado)

// upsert: si no existe lo crea
db.inventario.updateOne({ sku: "P01" }, { $set: { stock: 50 } }, { upsert: true });
```

**Operadores frecuentes:**

| Operador | Uso |
|:---|:---|
| `$set` | Asigna valor (crea campo si no existe) |
| `$unset` | Elimina el campo |
| `$inc` | Suma/resta numérico |
| `$push` | Agrega elemento al array |
| `$addToSet` | Agrega al array sin duplicar |
| `$pull` | Elimina elemento del array |
| `$currentDate` | Asigna fecha actual |

---

### 2.5 DELETE
```js
db.clientes.deleteOne({ email: "cris@valtx.pe" });
db.productos.deleteMany({ estado: "DESCONTINUADO" });
// ⚠️ deleteMany({}) borra TODA la colección
```
> 💡 En producción preferir **soft delete**: `$set: { deletedAt: new Date() }` en vez de borrar.

---

## 📌 Unidad 3: Gestión de Datos

### 3.1 find() vs findOne()

| | `find()` | `findOne()` |
|:---|:---|:---|
| Retorna | Cursor (encadenable) | Objeto o `null` |
| Cuándo usarlo | Listados, paginación | Búsqueda por ID / campo único |

---

### 3.2 Operadores de consulta

**Comparación:**
```js
{ precio: { $gte: 100, $lte: 500 } }
// $eq $ne $gt $gte $lt $lte $in $nin
db.clientes.find({ ciudad: { $in: ["Lima", "Arequipa"] } });
```

**Existencia:**
```js
{ email: { $exists: true } }   // campo presente (aunque sea null)
{ edad: { $type: "int" } }     // filtra por tipo BSON
```

**Lógica:**
```js
// AND implícito (lo más común)
db.productos.find({ precio: { $gt: 100 }, stock: { $gt: 0 } });

// OR
db.clientes.find({ $or: [{ ciudad: "Lima" }, { edad: { $gte: 60 } }] });

// NOR - ninguna condición se cumple
db.productos.find({ $nor: [{ precio: { $lt: 50 } }, { stock: 0 }] });
```

**Arrays:**
```js
{ tags: "oferta" }                          // busca el valor dentro del array
{ tags: { $all: ["tech", "oferta"] } }      // debe tener AMBOS
{ tags: { $size: 3 } }                      // longitud exacta
{ reviews: { $elemMatch: { usuario: "ana", puntaje: 5 } } } // condiciones en el MISMO elemento
```

**Subdocumentos — notación de punto:**
```js
db.clientes.find({ "direccion.ciudad": "Lima" }); // ✅ recomendado
db.clientes.find({ direccion: { ciudad: "Lima" } }); // ❌ requiere coincidencia exacta del objeto completo
```

---

### 3.3 Cursores
Orden real de ejecución: `find → sort → skip → limit → toArray`

```js
db.productos.find({ activo: true })
  .sort({ precio: -1 })     // 1 asc / -1 desc
  .skip(20)                 // paginación: (página - 1) * porPágina
  .limit(10)
  .toArray();               // ⚠️ carga todo en RAM, cuidado en colecciones grandes

db.productos.countDocuments({ stock: { $gt: 0 } }); // count() está deprecado
db.productos.estimatedDocumentCount();               // rápido, sin filtro
```

> ⚠️ `skip()` grande = lento. En producción paginar con `_id` como cursor en vez de skip.

## 📌 Unidad 4: Aggregation Framework
 
El **Aggregation Pipeline** es una secuencia de etapas (`stages`) que procesan documentos en orden. Cada stage transforma la colección y pasa el resultado al siguiente.
 
```js
db.coleccion.aggregate([
  { $match: { activo: true } },
  { $group: { _id: "$ciudad", total: { $sum: 1 } } },
  { $sort: { total: -1 } }
]);
```
 
---
 
### 4.1 Stages principales
 
**`$project`** — define qué campos mostrar/ocultar o crear campos calculados.
```js
{ $project: { nombre: 1, _id: 0, precioConIGV: { $multiply: ["$precio", 1.18] } } }
```
 
**`$match`** — filtra documentos (equivalente a `find()`). Siempre ponerlo lo más temprano posible para reducir datos.
```js
{ $match: { estado: "ACTIVO", stock: { $gt: 0 } } }
```
 
**`$group`** — agrupa documentos por un campo y aplica acumuladores. `_id` define el campo de agrupación.
```js
{ $group: {
    _id: "$categoria",
    totalProductos: { $sum: 1 },
    precioPromedio: { $avg: "$precio" },
    precioMax: { $max: "$precio" }
}}
// _id: null → agrupa TODO como un solo grupo
```
 
**`$sort`** — ordena. `1` asc / `-1` desc.
```js
{ $sort: { precioPromedio: -1 } }
```
 
**`$limit`** — limita cantidad de documentos que pasan al siguiente stage.
```js
{ $limit: 5 }
```
 
**`$skip`** — salta N documentos (paginación).
```js
{ $skip: 10 }
```
 
---
 
### 4.2 Operadores de expresión
 
**Agrupación (acumuladores — solo dentro de `$group`):**
 
| Operador | Uso |
|:---|:---|
| `$sum` | Suma valores (o `$sum: 1` para contar) |
| `$avg` | Promedio |
| `$min` / `$max` | Mínimo / máximo |
| `$first` / `$last` | Primer / último valor del grupo |
| `$push` | Acumula valores en un array |
| `$addToSet` | Igual que `$push` pero sin duplicados |
 
**Aritméticos:**
```js
{ $add: ["$precio", 10] }
{ $subtract: ["$total", "$descuento"] }
{ $multiply: ["$precio", "$cantidad"] }
{ $divide: ["$total", 2] }
{ $mod: ["$cantidad", 3] }
```
 
**Comparación (retornan boolean):**
```js
{ $eq: ["$estado", "ACTIVO"] }
{ $gt: ["$precio", 100] }
{ $gte: ["$stock", 0] }
// También: $ne $lt $lte
```
 
**Booleanos:**
```js
{ $and: [{ $gt: ["$precio", 50] }, { $lt: ["$precio", 200] }] }
{ $or:  [{ $eq: ["$estado", "A"] }, { $eq: ["$estado", "B"] }] }
{ $not: [{ $eq: ["$activo", false] }] }
```
 
**Condicionales:**
```js
// $cond — ternario: if / then / else
{ $cond: { if: { $gte: ["$stock", 10] }, then: "OK", else: "BAJO" } }
 
// $ifNull — valor por defecto si el campo es null/inexistente
{ $ifNull: ["$descuento", 0] }
 
// $switch — múltiples casos
{ $switch: {
    branches: [
      { case: { $gte: ["$nota", 90] }, then: "A" },
      { case: { $gte: ["$nota", 70] }, then: "B" }
    ],
    default: "C"
}}
```
 
**Cadenas:**
```js
{ $concat: ["$nombre", " - ", "$categoria"] }
{ $toUpper: "$nombre" }
{ $toLower: "$email" }
{ $substr: ["$codigo", 0, 3] }        // subcadena desde índice 0, longitud 3
{ $strLenCP: "$nombre" }              // longitud del string
{ $trim: { input: "$nombre" } }       // quita espacios
```
 
**Fechas:**
```js
{ $year: "$fechaRegistro" }
{ $month: "$fechaRegistro" }
{ $dayOfMonth: "$fechaRegistro" }
{ $dayOfWeek: "$fechaRegistro" }      // 1=domingo ... 7=sábado
{ $hour: "$fechaRegistro" }
{ $dateToString: { format: "%Y-%m-%d", date: "$fechaRegistro" } }
```
 
---
 
## 📌 Unidad 5: Optimización de MongoDB
 
### 5.1 Índices
 
Sin índice, MongoDB hace un **Collection Scan** (recorre todos los documentos). Con índice hace un **Index Scan** (mucho más rápido).
 
```js
// Crear índice simple
db.clientes.createIndex({ email: 1 });
 
// Índice compuesto (orden importa)
db.productos.createIndex({ categoria: 1, precio: -1 });
 
// Índice único
db.usuarios.createIndex({ email: 1 }, { unique: true });
 
// Índice con TTL — borra documentos automáticamente después de N segundos
db.sesiones.createIndex({ creadoEn: 1 }, { expireAfterSeconds: 3600 });
 
// Ver índices de una colección
db.clientes.getIndexes();
 
// Eliminar índice
db.clientes.dropIndex("email_1");
```
 
**Tipos de índice:**
 
| Tipo | Cuándo usarlo |
|:---|:---|
| Simple | Consultas frecuentes por un campo |
| Compuesto | Consultas que filtran/ordenan por varios campos |
| Único | Campos que no deben repetirse (email, DNI) |
| TTL | Datos temporales (sesiones, tokens, logs) |
| Texto | Búsqueda full-text en campos string |
| Wildcard | Cuando los campos del documento son dinámicos |
 
> ⚠️ Los índices aceleran lecturas pero **ralentizan escrituras** (INSERT/UPDATE/DELETE). No indexar todo, solo los campos que se consultan frecuentemente.
 
---
 
### 5.2 explain() — Analizar rendimiento de una consulta
 
`explain()` muestra cómo MongoDB ejecuta una consulta internamente.
 
```js
db.productos.find({ categoria: "TECH" }).explain("executionStats");
```
 
**Campos clave a revisar:**
 
| Campo | Qué indica |
|:---|:---|
| `winningPlan.stage` | `COLLSCAN` = sin índice (malo) / `IXSCAN` = con índice (bueno) |
| `totalDocsExamined` | Cuántos documentos recorrió |
| `totalDocsReturned` | Cuántos devolvió |
| `executionTimeMillis` | Tiempo en ms |
 
> 💡 Si `totalDocsExamined` >> `totalDocsReturned`, necesitas un índice.
 
---
 
### 5.3 Buenas prácticas generales
 
**Diseño de documentos:**
```js
// ✅ Embeber cuando los datos se consultan juntos siempre
{ nombre: "Cristian", direccion: { ciudad: "Lima", pais: "Perú" } }
 
// ✅ Referenciar cuando los datos crecen indefinidamente o se comparten
{ clienteId: ObjectId("...") } // referencia a otra colección
```
 
**Consultas:**
```js
// ✅ $match lo más temprano posible en el pipeline
// ✅ Proyectar solo los campos que necesitas
// ✅ Usar countDocuments() en vez de .find().toArray().length
// ⚠️ Evitar $where (ejecuta JS, lento y sin índice)
// ⚠️ Evitar skip() grande — usar cursor-based pagination
```
 
**Escrituras:**
```js
// ✅ insertMany() en vez de múltiples insertOne() en loop
// ✅ Operaciones bulk para updates masivos
const bulk = db.productos.initializeUnorderedBulkOp();
bulk.find({ stock: 0 }).update({ $set: { estado: "AGOTADO" } });
bulk.execute();
```
 
**Monitoreo:**
```js
db.currentOp()         // operaciones en ejecución ahora mismo
db.stats()             // estadísticas de la base de datos
db.coleccion.stats()   // estadísticas de una colección (tamaño, índices, etc.)
```

