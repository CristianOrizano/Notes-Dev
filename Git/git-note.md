# Git - Github

**cuando usamos por primera ves ponemos nuestro email**

- git config --global user.email cristianorizano57@gmail.com
- git config --global user.name CristianOrizano
- git config --global -l

**Flujo Git:**

- git init
- git add CodigoFuente
- git add .
- git commit -m ""

**Comandos Basicos:**

- git log --oneline

- git checkout 0ed124

- git remote add origin(conectar el repositorio local con el remoto)

- git push origin master (enviar cambios al repositorio remoto) 

- git remote set-url origin https://github.com/CristianOrizano/Mi_primer_Repository.git

- git remote --verbose ==> ver ruta de repositorio actual

- git clone url

>Obtener cambios de una rama remota 

git checkout -b Feature/Sanciones origin/Feature/Sanciones


// crear una rama

-git branch rama1 => crear
-git checkout rama1 => estar en la rama
-git checkout -b rama1 =>crear y ubicar

//cambiar rama

-git checkout rama1 => nos ubicamos en la rama
-git branch -m rama2 => modificamos nombre

//eliminar rama

-git checkout rama2 => nos debemos estar en la rama que vamos a delete
-git branch -d rama1 => elimina delete

//volver a una version anterior y que sea perman
git reset --hard b4e4f53b7d

//Fusionar rama
git merge rama2===>nos ubicamos en principal, y fusion

### Git Flow 

git flow init   >>>usar comandos basado en ramas
git flow feature start nombre-carater >>> se crea esa rama para hacer las caracteristicas
git flow feature finish nombre-caracter >>>elimina la rama y fusiona en automaticon con el develop

> estando en la rama develop, preparar lanzamiento

git flow release start 1.0.0 =====> se crea esa rama y empieza a crear commit de cambios.
git flow release finish 1.0.0 ====> finalizar rama de lanzamiento, y se fusiona con el main y develop, ademas se elimina esta rama en automatico

--:wq para el mensaje del release(despues de presionar esc)
