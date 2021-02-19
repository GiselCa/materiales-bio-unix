# Sesión II - Gestión avanzada y descarga de datos
Herramientas computacionales para bioinformática: UNIX, expresiones regulares y shell script

Edita esta plantilla en formato markdown [Guía aquí](https://guides.github.com/features/mastering-markdown/) como se pide en el guión. 
Cuando hayas acabado, haz un commit de tus cambios y súbelos al repositorio antes de la fecha de entrega señalada. 
Puedes usar el cliente 

======================================


## Ejercicio 1
Crea una copia de la carpeta gtfs. Luego crea enlaces duros y blandos a los ficheros .gtf y responde:

1. ¿Qué ocurre cuando se borra el origen y se intenta acceder al destino?
2. ¿Qué ocurre cuando se borra el destino y se intenta acceder al origen?
3. ¿Qué ocurre con la otra parte cuando se edita el destino o el origen del enlace?
4. ¿Qué ocurre cuando copiamos un enlace?

### Respuesta ejercicio 1

Primero vamos a crear un directorio con dos ficheros de texto y dos enlaces duros y blandos a cada uno para probar lo que se pide:

```
abenito@cpg3:~/sesion-ii$ mkdir pruebas-enlaces
abenito@cpg3:~/sesion-ii$ cd pruebas-enlaces/
abenito@cpg3:~/sesion-ii/pruebas-enlaces$ echo "Texto Fichero 1" > fichero_1.txt
abenito@cpg3:~/sesion-ii/pruebas-enlaces$ echo "Texto Fichero 2" > fichero_2.txt
abenito@cpg3:~/sesion-ii/pruebas-enlaces$ ln -s fichero_1.txt enlace_blando_fichero_1.txt
abenito@cpg3:~/sesion-ii/pruebas-enlaces$ ln fichero_2.txt enlace_duro_fichero_2.txt
abenito@cpg3:~/sesion-ii/pruebas-enlaces$ ln -s fichero_2.txt enlace_blando_fichero_2.txt
```


**¿Qué ocurre cuando se borra el origen y se intenta acceder al destino?**

Si borramos el origen de un enlace duro, el enlace sigue operativo. Sin embargo, si el enlace es blando, los datos se pierden. Si se restaura el origen, los datos vuelven a aparecer en el enlace blando.

```
abenito@cpg3:~/sesion-ii/pruebas-enlaces$ rm fichero_1.txt
abenito@cpg3:~/sesion-ii/pruebas-enlaces$ cat enlace_duro_fichero_1.txt
Texto Fichero 1
abenito@cpg3:~/sesion-ii/pruebas-enlaces$ cat enlace_blando_fichero_1.txt
cat: enlace_blando_fichero_1.txt: No existe el fichero o el directorio
abenito@cpg3:~/sesion-ii/pruebas-enlaces$ echo "Texto Fichero 1" > fichero_1.txt
abenito@cpg3:~/sesion-ii/pruebas-enlaces$ cat enlace_blando_fichero_1.txt
Texto Fichero 1
```

**¿Qué ocurre cuando se borra el destino y se intenta acceder al origen?**

No es problema, se sigue pudiendo acceder a los datos del origen.

```
abenito@cpg3:~/sesion-ii/pruebas-enlaces$ rm enlace_blando_fichero_2.txt
abenito@cpg3:~/sesion-ii/pruebas-enlaces$ rm enlace_duro_fichero_2.txt
abenito@cpg3:~/sesion-ii/pruebas-enlaces$ cat fichero_2.txt
Texto Fichero 2
abenito@cpg3:~/sesion-ii/pruebas-enlaces$ ln fichero_2.txt enlace_duro_fichero_2.txt
abenito@cpg3:~/sesion-ii/pruebas-enlaces$ ln -s fichero_2.txt enlace_blando_fichero_2.txt
```

**¿Qué ocurre con la otra parte cuando se edita el destino o el origen del enlace?**

Si modificamos el origen, los cambios se reflejan en los enlaces de ambos tipos:

```
abenito@cpg3:~/sesion-ii/pruebas-enlaces$ cat fichero_2.txt
Texto Fichero 2
abenito@cpg3:~/sesion-ii/pruebas-enlaces$ echo "modifico origen" >> fichero_2.txt
abenito@cpg3:~/sesion-ii/pruebas-enlaces$ cat enlace_duro_fichero_2.txt
Texto Fichero 2
modifico origen
abenito@cpg3:~/sesion-ii/pruebas-enlaces$ cat enlace_blando_fichero_2.txt
Texto Fichero 2
modifico origen
```

Si modificamos el enlace blando, los cambios se reflejan también en el origen y en el enlace duro:

```
abenito@cpg3:~/sesion-ii/pruebas-enlaces$ echo "modifico enlace blando" >> enlace_blando_fichero_2.txt
abenito@cpg3:~/sesion-ii/pruebas-enlaces$ cat enlace_blando_fichero_^C
abenito@cpg3:~/sesion-ii/pruebas-enlaces$ cat fichero_2.txt
Texto Fichero 2
modifico origen
modifico enlace blando
abenito@cpg3:~/sesion-ii/pruebas-enlaces$ cat enlace_duro_fichero_2.txt
Texto Fichero 2
modifico origen
modifico enlace blando
```

Si modificamos el enlace duro, los cambios se reflejan también en el origen y en el enlace blando:

```
abenito@cpg3:~/sesion-ii/pruebas-enlaces$ echo "modifico enlace duro" >> enlace_duro_fichero_2.txt
abenito@cpg3:~/sesion-ii/pruebas-enlaces$ cat enlace_duro_fichero_2.txt
Texto Fichero 2
modifico origen
modifico enlace blando
modifico enlace duro
abenito@cpg3:~/sesion-ii/pruebas-enlaces$ cat fichero_2.txt
Texto Fichero 2
modifico origen
modifico enlace blando
modifico enlace duro
abenito@cpg3:~/sesion-ii/pruebas-enlaces$ cat enlace_blando_fichero_2.txt
Texto Fichero 2
modifico origen
modifico enlace blando
modifico enlace duro
```

Aunque el efecto es el mismo para los dos tipos de enlace, es importante entender que internamente el funcionamiento es muy diferente: el enlace duro comparte el mismo inodo que el fichero original, pero es otro fichero diferente con todas las de la ley (tan sólo que apunta a los mismos datos que el fichero original).
En caso del enlace blando, éste tan sólo apunta al nombre del fichero original, pero no es un fichero "real". Por eso, cuando el origen se borra, el enlace deja de encontrar el nombre al que apuntaba y sus datos se pierden. Hasta que no se restaure otro fichero con el mismo nombre en la ruta original, el enlace blando apuntará a la nada. 

**¿Qué ocurre cuando copiamos un enlace?**

Empecemos copiando el enlace blando:

```
abenito@cpg3:~/sesion-ii/pruebas-enlaces$ cp enlace_blando_fichero_2.txt enlace_blando_fichero_2-copia.txt
abenito@cpg3:~/sesion-ii/pruebas-enlaces$ cp enlace_duro_fichero_2.txt enlace_duro_fichero_2-copia.txt
abenito@cpg3:~/sesion-ii/pruebas-enlaces$ ls -lai
total 32
150209328 drwxr-xr-x 2 abenito abenito 4096 ene 9 10:19 .
150209040 drwxr-xr-x 7 abenito abenito 4096 ene 8 14:42 ..
150209330 lrwxrwxrwx 1 abenito abenito   13 ene 9 09:29 enlace_blando_fichero_1.txt -> fichero_1.txt
150209060 -rw-r--r-- 1 abenito abenito   76 ene 9 10:09 enlace_blando_fichero_2-copia.txt
150209331 lrwxrwxrwx 1 abenito abenito   13 ene 9 09:36 enlace_blando_fichero_2.txt -> fichero_2.txt
150209332 -rw-r--r-- 2 abenito abenito   49 ene 9 09:43 enlace_duro_fichero_1.txt
150209336 -rw-r--r-- 1 abenito abenito   76 ene 9 10:19 enlace_duro_fichero_2-copia.txt
150209329 -rw-r--r-- 2 abenito abenito   76 ene 9 10:08 enlace_duro_fichero_2.txt
150209332 -rw-r--r-- 2 abenito abenito   49 ene 9 09:43 fichero_1.txt
150209329 -rw-r--r-- 2 abenito abenito   76 ene 9 10:08 fichero_2.txt
```

Como se observa, la copia de los enlaces duro y blando produce ficheros nuevos que contienen los datos del origen, pero que no estarán ligados ya más a dicho origen. El efecto es el mismo que se conseguiría copiando el origen directamente.


## Ejercicio 2
Usa la documentación de `find` para encontrar todos los notebook Jupyter con fecha de última modificación 30 de Noviembre de 2020 que haya en tu directorio HOME. Excluye todos aquellos que se encuentren dentro de directorios ocultos (aquellos que comienzan por un punto `.`). 


### Respuesta ejercicio 2
Para hacer lo que se pide, vamos a partir de la expresión `find $HOME -name "*ipynb" -type f`, que buscará en `$HOME` (en mi caso `/home/abenito`) todos los ficheros (`-type f`, debemos especificar esto porque podría haber directorios terminados en "ipynb" que no nos interesarían) que terminen en "ipynb" (`-name *ipynb`). 

En un segundo paso, vamos ahora a restringir la búsqueda a aquellos ficheros que se modificaron el día 30 de Noviembre de 2020. Si consultamos la ayuda, vemos que existe la opción `-newerXY`: 

```
       -newerXY reference
              Succeeds if timestamp X of the file being considered is newer than timestamp Y of the file reference.   The letters X and Y can be any of the following letters:

              a   The access time of the file reference
              B   The birth time of the file reference
              c   The inode status change time of reference
              m   The modification time of the file reference
              t   reference is interpreted directly as a time
```

Como buscamos los ficheros modificados y además tenemos una fecha en concreto, usaremos `-newermt '11/30/2020'`. Sin embargo, esto no será suficiente para dar con lo que estamos buscando, ya que `-newmrt` nos da aquellos modificados **a partir** de la fecha proporcionada. Para que devuelva sólo los ficheros con fecha de última modificación = 30/11/2020. Si navegamos el manual, veremos que no existe ninguna opción para realizar especificamente esto. Sin embargo, en la sección "OPERATORS" se nos dice que podemos encadenar operadores:

```
 OPERATORS
       Listed in order of decreasing precedence:

       ( expr )
              Force precedence.  Since parentheses are special to the shell, you will normally need to quote them.  Many of the examples in this  manual  page  use  backslashes  for  this  purpose:
              `\(...\)' instead of `(...)'.

       ! expr True if expr is false.  This character will also usually need protection from interpretation by the shell.

       -not expr
              Same as ! expr, but not POSIX compliant.
```

En concreto, la opción `!/-not` es interesante ya que es el operador de negación. Por tanto, podemos usarla para sacar los ficheros modificamos exactamente el día 30/11/2020. ¿Cuáles son esos? Aquellos cuya fecha de última modificación es posterior al 30/11/2020 **pero no** es posterior al 1/12/2020, o sea:

`find $HOME -type f -name "*ipynb" -newermt '11/30/2020' -not -newermt '12/1/2020'`

Si además queremos excluir aquellos que se encuentren en alguna ruta oculta, utilizaremos `-path`. Esta opción funciona igual que `-name` pero opera sobre toda la ruta del fichero: 

```
-path pattern
              File name matches shell pattern pattern.  The metacharacters do not treat `/' or `.' specially; so, for example,
                        find . -path "./sr*sc"
              will  print  an  entry for a directory called `./src/misc' (if one exists).  To ignore a whole directory tree, use -prune rather than checking every file in the tree.  For example, to
              skip the directory `src/emacs' and all files and directories under it, and print the names of the other files found, do something like this:
                        find . -path ./src/emacs -prune -o -print
              Note that the pattern match test applies to the whole file name, starting from one of the start points named on the command line.  It would only make sense to  use  an  absolute  path
              name here if the relevant start point is also an absolute path.  This means that this command will never match anything:
                        find bar -path /foo/bar/myfile -print
              Find  compares  the -path argument with the concatenation of a directory name and the base name of the file it's examining.  Since the concatenation will never end with a slash, -path
              arguments ending in a slash will match nothing (except perhaps a start point specified on the command line).  The predicate -path is also supported by HP-UX find and is  part  of  the
              POSIX 2008 standard.
```

Como los ficheros que queremos descartar contendrán `/.` en algún punto de su ruta absoluta, basta con excluirlos también usando `-not`. La expresión regular que captura esto es: `*/\.*`: (tenemos que escapar el punto ya que si no nos cogerá cualquier caracter). Al final nos queda:

```
find $HOME -name "*ipynb" -newermt '11/30/2020' -not -newermt '12/1/2020' -not -path '*/\.*'
```


## Ejercicio 3
Descarga, empleando la orden oportuna, todos los ficheros [de esta URL](ftp://ftp.ensembl.org/pub/release-102/gtf/accipiter_nisus/). 
- Inspecciona el fichero CHECKSUMS y genera los checksums adecuados para asegurarte de que los datos son íntegros. 
- Genera un fichero SHA-1 para todos los ficheros .gz descargados y documenta en esta memoria el comando con el que te descargaste los datos, adjuntando aquí los checksums. 


### Respuesta ejercicio 3
Para descargar todos los enlaces disponibles en la URL que se proporciona haremos:

`wget --no-directories --recursive --no-parent ftp://ftp.ensembl.org/pub/release-102/gtf/accipiter_nisus/`

Una vez descargados, inspecionamos el fichero CHECKSUMS:

```
abenito@cpg3:~/sesion-ii/prueba$ cat CHECKSUMS
28446  3388 Accipiter_nisus.Accipiter_nisus_ver1.0.102.abinitio.gtf.gz
35393  9369 Accipiter_nisus.Accipiter_nisus_ver1.0.102.gtf.gz
41355    10 README
```

Por el formato, parece claro que los checksums son CRC. Vamos a asegurarnos de que lo que hemos descargado es de verdad lo que hay alojado en el servidor:

```
abenito@cpg3:~/sesion-ii/prueba$ sum *.gtf* README
28446  3388 Accipiter_nisus.Accipiter_nisus_ver1.0.102.abinitio.gtf.gz
35393  9369 Accipiter_nisus.Accipiter_nisus_ver1.0.102.gtf.gz
41355    10 README
```

Efectivamente, vemos que concuerda. Para generar los checksums SHA-1 y documentar el proceso haremos: 

```
abenito@cpg3:~/sesion-ii/prueba$ shasum *.gtf* README
94408e910dd56ef4811dc6b3ee67a6c270f2c544  Accipiter_nisus.Accipiter_nisus_ver1.0.102.abinitio.gtf.gz
8a4fb7b736de257798de4b7cc963124555babade  Accipiter_nisus.Accipiter_nisus_ver1.0.102.gtf.gz
bd3f681149ec9c7ee3cbc2ac964540461cff3918  README
```

Una buena documentación que permitirá reproducir nuestra descarga de datos incluirá algo así:

#### Annotation Data
Mapa de anotaciones genómicas (Ensembl release 102) para el gavilán común (Accipiter nisus).
Descargado el 1 de enerero de 2021 a las 12:00 (GMT+1) con el comando:

`wget --no-directories --recursive --no-parent ftp://ftp.ensembl.org/pub/release-102/gtf/accipiter_nisus/`

####Sumas SHA-1
- `Accipiter_nisus.Accipiter_nisus_ver1.0.102.abinitio.gtf.gz`: 94408e910dd56ef4811dc6b3ee67a6c270f2c544
- `Accipiter_nisus.Accipiter_nisus_ver1.0.102.gtf.gz`: 8a4fb7b736de257798de4b7cc963124555babade