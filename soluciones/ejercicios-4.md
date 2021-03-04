# Sesión IV - Expresiones regulares: grep, sed y awk

Herramientas computacionales para bioinformática: UNIX, expresiones regulares y shell script

Edita esta plantilla en formato markdown [Guía aquí](https://guides.github.com/features/mastering-markdown/) como se pide en el guión. 
Cuando hayas acabado, haz un commit de tus cambios y súbelos al repositorio antes de la fecha de entrega señalada. 

======================================

**Añade por favor capturas de pantalla y el código de tus pipelines.**


## Ejercicio 1
Usando el fichero `aquella_voluntad.txt`, identifica usando grep:

1. El número de líneas que terminan por `o`. 
2. El número de líneas que terminan por `o` o por `a`. 
3. El número de líneas pares que terminan por `o` o por `a`
4. Todas las palabras que empiezan y acaban por `s` (ordenadas alfabéticamente)
5. Todas las palabras que no empiezan por t y acaban por `s`. (ordenadas por número de línea)
6. Todas las palabras que empiezan y acaban por la misma letra (volver a este punto al acabar toda la lección). 

### Respuesta ejercicio 1
#### 1. El número de líneas que terminan por `o`

Para contar líneas coincidentes con lo que se pide, emplearemos `grep -c` y una expresión regular. Simplemente usamos el metacaracter `$` para marcar el final de la línea: 

```
abenito@cpg3:~/sesion-iv$ grep -c "o$" aquella_voluntad.txt
60
```

#### 2. El número de líneas que terminan por `o` o por `a`
Igual que en el caso anterior, pero usaremos una clase de caracteres (`[]`) en vez de un único caracter:

```
abenito@cpg3:~/sesion-iv$ grep -c [oa]$ aquella_voluntad.txt
118
```

O usando alternancia (es necesario usar la opción -E):

```
abenito@cpg3:~/sesion-iv$ grep -cE "(o|a)$" aquella_voluntad.txt
118
```

#### 3. El número de líneas pares que terminan por `o` o por `a`
Este tiene un poco más de miga. Si consultas el manual, verás que `grep` soporta la opción `-n`, que da el ordinal de lineas que casan con la expresión regular proporcionada: 

```
abenito@cpg3:~/sesion-iv$ grep -n [oa]$ aquella_voluntad.txt | head -n5
7:a despecho y pesar de la ventura
12:   Y aún no se me figura que me toca
14:mas con la lengua muerta y fría en la boca
16:Libre mi alma de su estrecha roca
18:celebrándose irá, y aquel sonido
```

Ahora simplemente tenemos que enlazar esta salida a otro comando grep que identifique los numeros de línea que sean pares. ¿Cuáles son esos? Pues aquellos que terminen en número par: `0,2,4,6,8`. Para hacerlo sencillo, podemos fijarnos en que `grep -n` delimita el número de línea del texto con dos puntos `:`. Entonces, para capturar que la línea sea par, simplemente tendremos que asegurarnos de que el número que va antes de `:` sea uno de la clase `[02468]`:

```
abenito@cpg3:~/sesion-iv$ grep -n [oa]$ aquella_voluntad.txt | grep -c "[02468]:"
57
```


Otra forma de conseguir filtrar las líneas pares es usando una dirección con el comando `sed`. En la sección "Addresses" de la página del manual de `sed`, dice:

```
first~step
              Match  every  step'th line starting with line first.  For example, ``sed -n 1~2p''
              will print all the odd-numbered lines in the input stream,  and  the  address  2~5
              will match every fifth line, starting with the second.  first can be zero; in this
              case, sed operates as if it were equal to step.  (This is an extension.)
```

De manera que podemos hacer selecciones de líneas usando esa sintaxis. Además, como no queremos hacer ninguna sustitución, le diremos a `sed` que simplemente imprima (acción `p`). Si probamos ésto con nuestro fichero de texto:

```
abenito@cpg3:~/sesion-iv$ sed '2~2p' voluntad.txt | head
Aquella voluntad honesta y pura (Garcilaso de la Vega)


Aquella voluntad honesta y pura,
ilustre y hermosísima María,
ilustre y hermosísima María,
que en mí de celebrar tu hermosura,
tu ingenio y tu valor estar solía,
tu ingenio y tu valor estar solía,
a despecho y pesar de la ventura
```

Vemos que nos **repite** las líneas pares! Claro, como vimos en la sección 3.3, este es el comportamiento por defecto de `sed`. Para decirle que no imprima cuando no se lo indiquemos explícitamente, hemos de usar la opción `-n`. Luego, simplemente engancharemos esta salida a `grep` para que detecte las líneas terminadas en `o` o en `a` como hicimos antes:

```
abenito@cpg3:~/sesion-iv$ sed -n '2~2p' aquella_voluntad.txt | grep -c "[oa]$"
57
```

#### 4. Todas las palabras que empiezan y acaban por `s` (ordenadas alfabéticamente)

El mayor problema que plantea este ejercicio es que hay que considerar todas las palabras (y no sólo las líneas) que aparecen en el documento en cuestión, ya que si no podríamos "perdernos" ocurrencias del patrón que apareciesen junto a otras en la misma línea. Por lo tanto, para que grep nos saque todas las ocurrencias emplearemos la opción `-o`. Además, las palabras pueden comenzar por mayúscula y terminar por minúscula, así que le diremos a grep que la búsqueda no tenga en cuenta esta diferencia con la opción `-i`. 

Ahora nos queda dar con el patrón que casa con las palabras que empiezan y terminan por "s". Lo suyo es dividir el problema en dos tareas: primero, extraeremos todas las palabras del texto, y segundo, identificaremos cuáles de esas palabras comienzan y acaban por "s" (también podríamos hacerlo en un paso con el delimitador de comienzo/fin de palabra `\b`). Para lo primero, simplemente haremos:

```
abenito@cpg3:~/sesion-iv$ grep -Eoi "\w+" aquella_voluntad.txt | head -n10
Aquella
voluntad
honesta
y
pura
Garcilaso
de
la
Vega
Aquella
```

Y ahora filtramos la lista "pipeando" esta salida a otro grep en el que usaremos los delimitadores de inicio (`^`) y fin (`$`) de línea para indicarle dónde han de ir las "s". Finalmente, la salida de este comando la enlazamos al ya conocido combo `sort | uniq` para que nos saque una lista ordenada por frecuencia de las palabras encontradas:


```
abenito@cpg3:~/sesion-iv$ grep -Eo "\w+" aquella_voluntad.txt | grep -i "^s\w*s$" | sort | uniq -c | sort -nr
      7 sus
      2 selvas
      2 sauces
      1 sombras
      1 silvestres
      1 sentidos
      1 sendos
      1 sembradas
      1 salvajes
      1 sabemos
```


También podemos hacer lo mismo en una sola llamada a `grep` usando el metacaracter de límite de palabra `\b`. Este es un metacaracter "virtual" que está entre un caracter de palabra y otro de "no palabra".
```
abenito@cpg3:~/sesion-iv$ grep -ioE "\bs\w+s\b" aquella_voluntad.txt | sort | uniq -c | sort -nr
      7 sus
      2 selvas
      2 sauces
      1 sombras
      1 silvestres
      1 sentidos
      1 sendos
      1 sembradas
      1 salvajes
      1 sabemos
```


Bueno, pues, ¿ya estaría resuelto el ejercicio? No!! Y es que todavía ninguna de las soluciones planteadas hasta ahora es la más óptima (sorpresa!). Si hubiésemos **leído el manual**, habríamos podido saber que `grep` soporta la opción `-w`, que hace que la expresión regular que se pasa coincida sólo con palabras enteras:

```
-w, --word-regexp
              Select only those lines containing matches that form whole words.  The test is that the matching substring must
              either be at the beginning of the line, or preceded by a non-word constituent character.  Similarly, it must be
              either at the end of the line or followed by a non-word constituent character.  Word-constituent characters are
              letters, digits, and the underscore.  This option has no effect if -x is also specified.
```

Por lo tanto, podemos ahorrarnos extraer las palabras o tener que usar el metacaracter `\b` y simplemente usar la expresión regular en su forma más sencilla.

```
abenito@cpg3:~/sesion-iv$ grep -Eiow "s\w+s" aquella_voluntad.txt | sort | uniq 
      7 sus
      2 selvas
      2 sauces
      1 sombras
      1 silvestres
      1 sentidos
      1 sendos
      1 sembradas
      1 salvajes
      1 sabemos
```



#### 5. Todas las palabras que no empiezan por t y acaban por `s` (ordenadas por número de línea)
Este ejercicio es muy similar al anterior, simplemente modificamos la expresión regular anterior definiendo la clase de caracteres que no son "t": `[^t]`. Además, podemos sacar el número de línea con la opción `-n` (en realidad no será el número de línea, será la posición en el índice total de palabras, pero nos vale para resolver "empates"). Si lo probamos...

```
abenito@cpg3:~/sesion-iv$ grep -nEiow "[^t]\w+s" aquella_voluntad.txt | head -n5
14:mas
19:las
19:aguas
21: Mas
24:maneras
```

...parece que funciona. Pero espera! Si te fijas, la cuarta palabra que ha encontrado tiene un espacio al principio! ¿Por qué ha ocurrido esto? Lo que pasa es que `grep` está expandiendo la expresión regular de acuerdo a su naturaleza _avariciosa_ para casar con el mayor número posible de caracteres. Como le decimos que la palabra ha de empezar por cualquier caracter que no sea "t" (`[^t]`), eso incluye también caracteres "de no palabra" (de hecho, cualquier cosa que no sea literalmente la letra "t"). Pero como algunas palabras tienen dos caracteres de no palabra antes (comas, símbolos de interrogación, espacios, etc) pues coge también el inmediatamente anterior a la primera letra de la palabra.

Esto representa un problema, porque si tratamos de encontrar palabras únicas, aquellas con espacios u otrs caracteres al principio contarán como entidades separadas, lo cual no sería muy correcto. Así que mejor arreglamos nuestra expresión regular para que coja sólo letras y además lo pasamos todo a minúsculas:

```
abenito@cpg3:~/sesion-iv$ grep -nEiow "[a-z^t]\w+s" aquella_voluntad.txt | tr 'A-Z' 'a-z' | head -n5
14:mas
19:las
19:aguas
21:mas
24:maneras
```


Ahora vamos a eliminar palabras repetidas y a ordenarlas de manera que las palabras que aparezcan antes en el texto salgan más arriba en la lista. Pero un simple `sort | uniq` no nos vale ahora. Es necesario eliminar las ocurrencias (lo que va detrás de `:`) repetidas. Para esto, le diremos a `sort` que genere una lista única con la opción `-u` (lo que sería equivalente a `sort | uniq`) considerando la segunda columna (`-k2,2`) y el caracter de división `-t:`:

```
abenito@cpg3:~/sesion-iv$ grep -nEiow "[a-z^t]\w+s" aquella_voluntad.txt | tr 'A-Z' 'a-z' | sort -u -t: -k2,2 | head -n10
91:abejas
397:abrojos
210:adonis
19:aguas
413:alcides
244:altas
383:altísimos
311:altos
130:antes
240:antiguos
```

Ahora sólo nos queda volver a ordenar las filas numéricamente con `sort -n` para obtener el resultado esperado:

```
abenito@cpg3:~/sesion-iv$ grep -nEiow "[a-z^t]\w+s" aquella_voluntad.txt | tr 'A-Z' 'a-z' | sort -u -t: -k2,2 | sort -n | head -n10
14:mas
19:aguas
19:las
24:maneras
25:más
27:cuidados
27:vanos
28:manos
32:jamás
34:hermanas
```

Si nos asegurásemos de que cada palabra tiene un índice único al final (_¿sabrías hacerlo en un único último paso?_), habríamos creado lo que se conoce como **índice de palabras** o **diccionario**.

La creación de los índices de palabras es una de las tareas más básicas del [procesamiento del lenguaje natural](https://es.wikipedia.org/wiki/Procesamiento_de_lenguajes_naturales), un apasionante campo de la computación con muchísimas aplicaciones en [bioinformática](https://bmcbioinformatics.biomedcentral.com/articles/10.1186/s12859-018-2079-4) e [informática médica](https://scielo.conicyt.cl/scielo.php?script=sci_arttext&pid=S0034-98872019001001229)).

#### 6. Todas las palabras que empiezan y acaban por la misma letra (volver a este punto al acabar toda la lección)
Si intentaste resolver este ejercicio sólo con lo explicado hasta el punto 1 de la lección, quizás te diste cuenta que encontrar una solución implicaba llevar a cabo un proceso manual bastante tedioso. Una manera bastante obvia (e ineficiente) era adaptar la solución del anterior apartado e ir probando todas las letras del alfabeto una por una, así:

```
abenito@cpg3:~/sesion-iv$ grep -Eiow "a\w+a" aquella_voluntad.txt | sort -u | head -n5
abierta
abundancia
acompañada
adornada
agua
abenito@cpg3:~/sesion-iv$ grep -Eiow "b\w+b" aquella_voluntad.txt | sort -u | head -n5
abenito@cpg3:~/sesion-iv$ grep -Eiow "c\w+c" aquella_voluntad.txt | sort -u | head -n5
abenito@cpg3:~/sesion-iv$ grep -Eiow "d\w+d" aquella_voluntad.txt | sort -u | head -n5
abenito@cpg3:~/sesion-iv$ grep -Eiow "e\w+e" aquella_voluntad.txt | sort -u | head -n5
elocuente
entre
Entre
estambre
este
.
.
.
```

Vaya rollo! Si tan solo existiese una manera de decirle a `grep` que queremos que el primer y último caracteres sean el mismo! 

Por suerte, más adelante, en el punto 3.1 de la lección, te mostré que esto se puede conseguir con referencias hacia atrás y grupos de captura! La idea es capturar la primera letra de la palabra en un grupo y referenciarlo desde el último caracter de la palabra. 
Si adaptamos la expresión regular de los apartados anteriores para que use un grupo de captura, nos queda:

```
abenito@cpg3:~/sesion-iv$ grep -Eiow "([a-z])\w+\1" aquella_voluntad.txt | tr 'A-Z' 'a-z' | sort -u | head -n10
abierta
abundancia
acompañada
adornada
agua
airada
alabanza
alegría
alma
alta
```

## Ejercicio 2
¿Cuántos gene_ids existen con varios ceros seguidos en los dos gtfs (Humano y Drosophila)?. ¿Cuáles son? ¿Cuántas veces aparece cada uno en el .gtf dado?
Explora el fichero de anotaciones para ver si existen otros gene_ids con muchos números seguidos iguales.

### Respuesta ejercicio 2
Este ejercicio es muy parecido al que hicimos en la tercera lección, con la diferencia de que ahora tenemos que crear una expresión regular que nos identique los gene_ids con la forma que nos interesa. Primero echamos un vistazo al fichero de anotaciones de la Drosophila, para ver cómo aparecen los ids:

```
abenito@cpg3:~/sesion-iv/gtfs$ grep -v "^#" Drosophila_melanogaster.BDGP6.28.102.gtf | head -n2 | column -t
3R  FlyBase  gene        567076  2532932  .  +  .  gene_id  "FBgn0267431";  gene_name      "Myo81F";       gene_source  "FlyBase";  gene_biotype  "protein_coding";
3R  FlyBase  transcript  567076  2532932  .  +  .  gene_id  "FBgn0267431";  transcript_id  "FBtr0392909";  gene_name    "Myo81F";   gene_source   "FlyBase";         gene_biotype  "protein_coding";  transcript_source  "FlyBase";  transcript_biotype  "protein_coding";
```

Aquí podemos observar que nos va a interesar encontrar ocurrencias del tipo `gene_id "<id del gen>";`: o sea, la cadena `gene_id`, seguida de un espacio, seguido de comillas dobles (`"`), seguido de varios caracteres de palabra, seguido de comillas dobles de nuevo y terminado en punto y coma (`;`).
 
Como sólo habra un `gene_id` por línea, basta con volver a usar la opción `-o` con `grep` para extraer la cadena coincidente. Los ids estarán formados por números y letras, que encaja con la clase de caracteres de palabra (shorthand `\w`). Vamos a ver primero cuántos gene_ids (de cualquier tipo podemos encontrar en cada uno de los ficheros usando la expresión regular `gene_id "\w+"` (date cuenta de que esta expresión se la pasamos a `grep` usando comillas simples, ya que nuestra expresión regular contiene comillas dobles):

```
abenito@cpg3:~/sesion-iv/gtfs$ grep -v "^#" Drosophila_melanogaster.BDGP6.28.102.gtf | wc -l
543508
abenito@cpg3:~/sesion-iv/gtfs$ grep -Eo 'gene_id "\w+"' Drosophila_melanogaster.BDGP6.28.102.gtf | sort | uniq | wc -l
17807

abenito@cpg3:~/sesion-iv/gtfs$ zgrep -v "^#" Homo_sapiens.GRCh38.102.gtf.gz | wc -l
3010595
abenito@cpg3:~/sesion-iv/gtfs$ zgrep -Eo 'gene_id "\w+"' Homo_sapiens.GRCh38.102.gtf.gz | sort -u | wc -l
60675
```

Como se puede ver, el fichero de anotaciones para la _Drosophila Melanogaster_ contiene aproximadamente medio millón de líneas y 17.807 ids de gen distintos. Por su parte, el fichero de anotaciones del genoma humano contiene aproximadamente tres millones de líneas y 60.675 ids distintos.

En cualquier punto de la cadena que forma el id, detectaremos apariciones de 3 o más (varios) ceros indicando que puede haber cero o varios caracteres de palabra (`\w*`) antes o después de la secuencia de ceros. Por tanto, creamos la expresión regular `gene_id "\w*0{3}\w*"`, que va a capturar precisamente esto. Fíjate en que no hace falta indicar el límite superior de ceros que queremos encontrar, ya que por definición cualquier cadena con cuatro o más ceros seguidos tendrá también "tres o más". Además, podemos mejorar la presentación de los datos eliminando las comillas dobles con `sed`, y ordenar la lista que obtenemos por número de apariciones de cada id, de mayor a menor (`sort -nr`) creando un fichero intermedio `Drosophila_gene_ids-ordenado.txt`:

```
abenito@cpg3:~/sesion-iv/gtfs$ grep -Eo 'gene_id "\w*0{3}\w*"' Drosophila_melanogaster.BDGP6.28.102.gtf | sed -E 's/gene_id "(\w+)"/\1/' | sort | uniq -c | sort -nr > Drosophila-gene_ids-dist-ordenada.txt
abenito@cpg3:~/sesion-iv/gtfs$ wc -l Drosophila-gene_ids-dist-ordenada.txt
1038 Drosophila-gene_ids-dist-ordenada.txt
abenito@cpg3:~/sesion-iv/gtfs$ head -n5 Drosophila-gene_ids-dist-ordenada.txt
   1204 FBgn0003429
    705 FBgn0260003
    703 FBgn0001991
    602 FBgn0001624
    597 FBgn0005536
```

O sea, hay 1038 ids de gen de 17807 (~5.8%) que contienen 3 o más ceros.

Y de manera análoga para el gtf del _Homo Sapiens_:

```
abenito@cpg3:~/sesion-iv/gtfs$ zgrep -Eo 'gene_id "\w*0{3}\w*"' Homo_sapiens.GRCh38.102.gtf.gz | sed -E 's/gene_id "(\w+)"/\1/' | sort | uniq -c | sort -nr > HomoSapiens-gene_ids-dist-ordenada.txt
abenito@cpg3:~/sesion-iv/gtfs$ wc -l HomoSapiens-gene_ids-dist-ordenada.txt
60675 HomoSapiens-gene_ids-dist-ordenada.txt
abenito@cpg3:~/sesion-iv/gtfs$ head -n5 HomoSapiens-gene_ids-dist-ordenada.txt
   7081 ENSG00000145362
   4603 ENSG00000109339
   4369 ENSG00000156113
   3439 ENSG00000155657
   3058 ENSG00000224078
```

En este caso, se observa que hay 60.675 ids de gen de 60.675 (100%) con 3 o más ceros.

## Ejercicio 3

Crea un pipeline que convierta un fichero fasta con secuencias partidas en múltiples líneas en otro sin saltos de línea. 
Al final, para cada secuencia, imprimirá su nombre y el número de caracteres que tenga. 

### Respuesta ejercicio 3

Como ya nos es conocido, vamos a probar nuestra solución con el fichero `covid-samples.fasta`, que en la sesión anterior pudimos saber que contenía cuatro secuencias y 1.995 líneas en total:

```
abenito@cpg3:~/sesion-iv/fasta$ grep ">" covid-samples.fasta | wc -l
4
abenito@cpg3:~/sesion-iv/fasta$ wc -l covid-samples.fasta
1995 covid-samples.fasta
```

Quizás te hayas encontrado dificultades al intentar eliminar los saltos de línea directamente con `sed`:

```
abenito@cpg3:~/sesion-iv/fasta$ sed 's/\n//g' covid-samples.fasta | head -n10
>MW186669.1 |Severe acute respiratory syndrome coronavirus 2 isolate SARS-CoV-2/human/EGY/Cairo-sample 19 MOH/2020, complete genome
GTTTATACCTTCCCAGGTAACAAACCAACCAACTTTCGATCTCTTGTAGATCTGTTCTCT
AAACGAACTTTAAAATCTGTGTGGCTGTCACTCGGCTGCATGCTTAGTGCACTCACGCAG
TATAATTAATAACTAATTACTGTCGTTGACAGGACACGAGTAACTCGTCTATCTTCTGCA
GGCTGCTTACGGTTTCGTCCGTGTTGCAGCCGATCATCAGCACATCTAGGTTTTGTCCGG
GTGTGACCGAAAGGTAAGATGGAGAGCCTTGTCCCTGGTTTCAACGAGAAAACACACGTC
CAACTCAGTTTGCCTGTTTTACAGGTTCGCGACGTGCTCGTACGTGGCTTTGGAGACTCC
GTGGAGGAGGTCTTATCAGAGGCACGTCAACATCTTAAAGATGGCACTTGTGGCTTAGTA
GAAGTTGAAAAAGGCGTTTTGCCTCAACTTGAACAGCCCTATGTGTTCATCAAACGTTCG
GATGCTCGAACTGCACCTCATGGTCATGTTATGGTTGAGCTGGTAGCAGAACTCGAAGGC
```

Como ves, esto no funciona! Por qué? Pues porque `sed`, al igual que muchas de las otras herramientas que hemos visto, entiende la línea como unidad básica de procesamiento, esto es, los streams de texto que le pasaremos contienen porciones delitadas por caracteres de salto de línea (`\n`). 

Por lo tanto, la solución para eliminar dichos saltos de línea implica conseguir que `sed` deje de interpretar estos saltos de línea como separadores básicos para su funcionamiento (ver posible solución [aquí](https://stackoverflow.com/a/1252191/655221)) y vaya juntando las líneas como le decimos para formar nuevas líneas, lo cual implica tener que ir hasta un nivel muy bajo y usar expresiones "muy raras" para que `sed` entienda qué es lo que queremos.

Aunque después de mucho tiempo consiguiésemos dar con la tecla, es más interesante reparar en por qué una tarea tan sencilla se ha tornado sumamente compleja y se ha llevado tantas horas de nuestro preciado tiempo. Como ocurre en el mundo real, cuando nos pase esto en un ordenador es muy útil, antes de aventurarse a perder mucho tiempo resolviendo una tarea a-priori trivial, plantearse si estamos usando **la mejor herramienta disponible para el fin que buscamos** (cuánto se tarda en desatornillar un tornillo con un destornillador? Y usando unas pinzas? Y un martillo?). La gran mayoría de las veces llegaremos a la conclusión de que es mucho más útil **buscar y aprender a usar** una herramienta adecuada que no intentar desatornillar el tornillo con la primera cosa que tengamos a mano. 

Así que si hacemos esta reflexión, podremos comprobar que en efecto, `sed` no es la herramienta adecuada para eliminar saltos de línea: existe una herramienta diseñada específicamente para este fin (bueno, en realidad para procesar streams de texto caracter a caracter) que hemos visto en clase: `tr`. Pero claro, si le decimos que elimine todos los saltos de línea, vamos a obtener una sóla línea, que no es lo queremos:

```
abenito@cpg3:~/sesion-iv/fasta$ cat covid-samples.fasta | tr -d "\n" | wc -l
0
```

Porque en realidad, _no queremos eliminar todos los saltos de línea_, en realidad queremos mantener _algunos_ saltos de línea: el de la línea que contiene el nombre de la secuencia y el de la última línea de la secuencia. 

Para resolver este problema, sólo basta con echarle un poquito de imaginación: usando `sed` vamos a marcar con el caracter `$` los saltos de línea que **no queremos eliminar** antes de llamar a `tr` para que los elimine todos. Posteriormente, restauraremos los saltos de línea para que el resultado nos quede como esperamos. 

Primero, marcamos antes y después de cada línea con nombres de secuencia (la que empieza con el caracter `>`):

```
abenito@cpg3:~/sesion-iv/fasta$ sed -E 's/^(>.+)/$\1$/' covid-samples.fasta | head -n5
$>MW186669.1 |Severe acute respiratory syndrome coronavirus 2 isolate SARS-CoV-2/human/EGY/Cairo-sample 19 MOH/2020, complete genome$
GTTTATACCTTCCCAGGTAACAAACCAACCAACTTTCGATCTCTTGTAGATCTGTTCTCT
AAACGAACTTTAAAATCTGTGTGGCTGTCACTCGGCTGCATGCTTAGTGCACTCACGCAG
TATAATTAATAACTAATTACTGTCGTTGACAGGACACGAGTAACTCGTCTATCTTCTGCA
GGCTGCTTACGGTTTCGTCCGTGTTGCAGCCGATCATCAGCACATCTAGGTTTTGTCCGG
```

Ahora usamos dos llamadas a `tr`, para eliminar y restaurar los saltos de línea:

```
abenito@cpg3:~/sesion-iv/fasta$ sed -E 's/^(>.+)/$\1$/' covid-samples.fasta | tr -d "\n" | tr '$' '\n' | head -n3

>MW186669.1 |Severe acute respiratory syndrome coronavirus 2 isolate SARS-CoV-2/human/EGY/Cairo-sample 19 MOH/2020, complete genome
GTTTATACCTTCCCAGGTAACAAACCAACCAACTTTCGATCTCTTGTAGATCTGTTCTCTAAACGAACTTTAAAATCTGTGTGGCTGTCACTCGGCTGCATGCTTAGTGCACTCACGCAGTATAATTAATAACTAATTACTGTCGTTGACAGGACACGAGTAACTCGTCTATCTTCTGCAGGCTGCTTACGGTTTCGTCCGTGTTGCAGCCGATCATCAGCACATCTAGGTTTTGTCCGGGTGTGACCGAAAGGTAAGATGGAGAGCCTTGTCCCTGGTTTCAACGAGAAAACACACGTCCAACTCAGTTTGCCTGTTTTACAGGTTCGCGACGTGCTCGTACGTGGCTTTGGAGACTCCGTGGAGGAGGTCTTATCAGAGGCACGTCAACATCTTAAAGATGGCACTTGTGGCTTAGTAGAAGTTGAAAAAGGCGTTTTGCCTCAACTTGAACAGCCCTATGTGTTCATCAAACGTTCGGATGCTCGAACTGCACCTCATGGTCATGTTATGGTTGAGCTGGTAGCAGAACTCGAAGGCATTCAGTACGGTCGTAGTGGTGAGACACTTGGTGTCCTTGTCCCTCATGTGGGCGAAATACCAGTGGCTTACCGCAAGGTTCTTCTTCGTAAGAACGGTAATAAAGGAGCTGGTGGCCATAGTTACGGCGCCGATCTAAAGTCATTTGACTTAGGCGACGAGCTTGGCACTGATCCTTATGAAGATTTTCAAGAAAACTGGAACACTAAACATAGCAGTGGTGTTACCCGTGAACTCATGCGTGAGCTTAACGGAGGGGCATACACTCGCTATGTCGATAACAACTTCTGTGGCCCTGATGGCTACCCTCTTGAGTGCATTAAAGACCTTCTAGCACGTGCTGGTAAAGCTTCATGCACTTTGTCCGAACAACTGGACTTTATTGACACTAAGAGGGGTGTATACTGCTGCCGTGAACATGAGCATGAAATTGCTTGGTMCMCGGAACGTTCTGAAAAGAGCTATGAATTGCAGACACCTTTTGAAATTAAATTGGCAAAGAAATTTGACACCTTCAATGGGGAATGTCCAAATTTTGTATTTCCCTTAAATTCCATAATCAAGACTATTCAACCAAGGGTTGAAAAGAAAAAGCTTGATGGCTTTATGGGTAGAATTCGATCTGTCTATCCAGTTGCGTCACCAAATGAATGCAACCAAATGTGCCTTTCAACTCTCATGAAGTGTGATCATTGTGGTGAAACTTCATGGCAGACGGGCGATTTTGTTAAAGCCACTTGCGAATTTTGTGGCACTGAGAATTTGACTAAAGAAGGTGCCACTACTTGTGGTTACTTACCCCAAAATGCTGTTGTTAAAATTTATTGTCCAGCATGTCACAATTCAGAAGTAGGACCTGAGCATAGTCTTGCCGAATACCATAATGAATCTGGCTTGAAAACCATTCTTCGTAAGGGTGGTCGCACTATTGCCTTTGGAGGCTGTGTGTTCTCTTATGTTGGTTGCCATAACAAGTGTGCCTATTGGGTTCCACGTGCTAGCGCTAACATAGGTTGTAACCATACAGGTGTTGTTGGAGAAGGTTCCGAAGGTCTTAATGACAACCTTCTTGAAATACTCCAAAAAGAGAAAGTCAACATCAATATTGTTGGTGACTTTAAACTTAATGAAGAGATCGCCATTATTTTGGCATCTTTTTCTGCTTCCACAAGTGCTTTTGTGGAAACTGTGAAAGGTTTGGATTATAAAGCATTCAAACAAATTGTTGAATCCTGTGGTAATTTTAAAGTTACAAAAGGAAAAGCTAAAAAAGGTGCCTGGAATATTGGTGAACAGAAATCAATACTGAGTCCTCTTTATGCATTTGCATCAGAGGCTGCTCGTGTTGTACGATCAATTTTCTCCCGCACTCTTGAAACTGCTCAAAATTCTGTGCGTGTTTTACAGAAGGCCGCTATAACAATACTAGATGGAATTTCACAGTATTCACTGAGACTCATTGATGCTATGATGTTCACATCTGATTTGGCTACTAACAATCTAGTTGTAATGGCCTACATTACAGGTGGTGTTGTTCAGTTGACTTCGCAGTGGCTAACTAACATCTTTGGCACTGTTTATGAAAAACTCAAACCCGTCCTTGATTGGCTTGAAGAGAAGTTTAAGGAAGGTGTAGAGTTTCTTAGAGACGGTTGGGAAATTGTTAAATTTATCTCAACCTGTGCTTGTGAAATTGTCGGTGGACAAATTGTCACCTGTGCAAAGGAAATTAAGGAGAGTGTTCAGACATTCTTTAAGCTTGTAAATAAATTTTTGGCTTTGTGTGCTGACTCTATCATTATTGGTGGAGCTAAACTTAAAGCCTTGAATTTAGGTGAAACATTTGTCACGCACTCAAAGGGATTGTACAGAAAGTGTGTTAAATCCAGAGAAGAAACTGGCCTACTCATGCCTCTAAAAGCCCCAAAAGAAATTATCTTCTTAGAGGGAGAAACACTTCCCACAGAAGTGTTAACAGAGGAAGTTGTCTTGAAAACTGGTGATTTACAACCATTAGAACAACCTACTAGTGAAGCTGTTGAAGCTCCATTGGTTGGTACACCAGTTTGTATTAACGGGCTTATGTTGCTCGAAATCAAAGACACAGAAAAGTACTGTGCCCTTGCACCTAATATGATGGTAACAAACAATACCTTCACACTCAAAGGCGGTGCACCAACAAAGGTTACTTTTGGTGATGACACTGTGATAGAAGTGCAAGGTTACAAGAGTGTGAATATCACTTTTGAACTTGATGAAAGGATTGATAAAGTACTTAATGAGAAGTGCTCTGCCTATACAGTTGAACTCGGTACAGAAGTAAATGAGTTCGCCTGTGTTGTGGCAGATGCTGTCATAAAAACTTTGCAACCAGTATCTGAATTACTTACACCACTGGGCATTGATTTAGATGAGTGGAGTATGGCTACATACTACTTATTTGATGAGTCTGGTGAGTTTAAATTGGCTTCACATATGTATTGTTCTTTTTACCCTCCAGATGAGGATGAAGAAGAAGGTGATTGTGAAGAAGAAGAGTTTGAGCCATCAACTCAATATGAGTATGGTACTGAAGATGATTACCAAGGTAAACCTTTGGAATTTGGTGCCACTTCTGCTGCTCTTCAACCTGAAGAAGAGCAAGAAGAAGATTGGTTAGATGATGATAGTCAACAAACTGTTGGTCAACAAGACGGCAGTGAGGACAATCAGACAACTACTATTCAAACAATTGTTGAGGTTCAACCTCAATTAGAGATGGAACTTACACCAGTTGTTCAGACTATTGAAGTGAATAGTTTTAGTGGTTATTTAAAACTTACTGACAATGTATACATTAAAAATGCAGACATTGTGGAAGAAGCTAAAAAGGTAAAACCAACAGTGGTTGTTAATGCAGCCAATGTTTACCTTAAACATGGAGGAGGTGTTGCAGGAGCCTTAAATAAGGCTACTAACAATGCCATGCAAGTTGAATCTGATGATTACATAGCTACTAATGGACCACTTAAAGTGGGTGGTAGTTGTGTTTTAAGCGGACACAATCTTGCTAAACACTGTCTTCATGTTGTCGGCCCAAATGTTAACAAAGGTGAAGACATTCAACTTCTTAAGAGTGCTTATGAAAATTTTAATCAGCACGAAGTTCTACTTGCACCATTATTATCAGCTGGTATTTTTGGTGCTGACCCTATACATTCTTTAAGAGTTTGTGTAGATACTGTTCGCACAAATGTCTACTTAGCTGTCTTTGATAAAAATCTCTATGACAAACTTGTTTCAAGCTTTTTGGAAATGAAGAGTGAAAAGCAAGTTGAACAAAAGATCGCTGAGATTCCTAAAGAGGAAGTTAAGCCATTTATAACTGAAAGTAAACCTTCAGTTGAACAGAGAAAACAAGATGATAAGAAAATCAAAGCTTGTGTTGAAGAAGTTACAACAACTCTGGAAGAAACTAAGTTCCTCACAGAAAACTTGTTACTTTATATTGACATTAATGGCAATCTTCATCCAGATTCTGCCACTCTTGTTAGTGACATTGACATCACTTTCTTAAAGAAAGATGCTCCATATATAGTGGGTGATGTTGTTCAAGAGGGTGTTTTAACTGCTGTGGTTATACCTACTAAAAAGGCTGGTGGCACTACTGAAATGCTAGCGAAAGCTTTGAGAAAAGTGCCAACAGACAATTATATAACCACTTACCCGGGTCAGGGTTTAAATGGTTACACTGTAGAGGAGGCAAAGACAGTGCTTAAAAAGTGTAAAAGTGCCTTTTACATTCTACCATCTATTATCTCTAATGAGAAGCAAGAAATTCTTGGAACTGTTTCTTGGAATTTGCGAGAAATGCTTGCACATGCAGAAGAAACACGCAAATTAATGCCTGTCTGTGTGGAAACTAAAGCCATAGTTTCAACTATACAGCGTAAATATAAGGGTATTAAAATACAAGAGGGTGTGGTTGATTATGGTGCTAGATTTTACTTTTACACCAGTAAAACAACTGTAGCGTCACTTATCAACACACTTAACGATCTAAATGAAACTCTTGTTACAATGCCACTTGGCTATGTAACACATGGCTTAAATTTGGAAGAAGCTGCTCGGTATATGAGATCTCTCAAAGTGCCAGCTACAGTTTCTGTTTCTTCACCTGATGCTGTTACAGCGTATAATGGTTATCTTACTTCTTCTTCTAAAACACCTGAAGAACATTTTATTGAAACCATCTCACTTGCTGGTTCCTATAAAGATTGGTCCTATTCTGGACAATCTACACAACTAGGTATAGAATTTCTTAAGAGAGGTGATAAAAGTGTATATTACACTAGTAATCCTACCACATTCCACCTAGATGGTGAAGTTATCACCTTTGACAATCTTAAGACACTTCTTTCTTTGAGAGAAGTGAGGACTATTAAGGTGTTTACAACAGTAGACAACATTAACCTCCACACGCAAGTTGTGGACATGTCAATGACATATGGACAACAGTTTGGTCCAACTTATTTGGATGGAGCTGATGTTACTAAAATAAAACCTCATAATTCACATGAAGGTAAAACATTTTATGTTTTACCTAATGATGACACTCTACGTGTTGAGGCTTTTGAGTACTACCACACAACTGATCCTAGTTTTCTGGGTAGGTACATGTCAGCATTAAATCACACTAAAAAGTGGAAATACCCACAAGTTAATGGTTTAACTTCTATTAAATGGGCAGATAACAACTGTTATCTTGCCACTGCATTGTTAACACTCCAACAAATAGAGTTGAAGTTTAATCCACCTGCTCTACAAGATGCTTATTACAGAGCAAGGGCTGGTGAAGCTGCTAACTTTTGTGCACTTATCTTAGCCTACTGTAATAAGACAGTAGGTGAGTTAGGTGATGTTAGAGAAACAATGAGTTACTTGTTTCAACATGCCAATTTAGATTCTTGCAAAAGAGTCTTGAACGTGGTGTGTAAAACTTGTGGACAACAGCAGACAACCCTTAAGGGTGTAGAAGCTGTTATGTACATGGGCACACTTTCTTATGAACAATTTAAGAAAGGTGTTCAGATACCTTGTACGTGTGGTAAACAAGCTACAAAATATCTAGTACAACAGGAGTCACCTTTTGTTATGATGTCAGCACCACCTGCTCAGTATGAACTTAAGCATGGTACATTTACTTGTGCTAGTGAGTACACTGGTAATTACCAGTGTGGTCACTATAAACATATAACTTCTAAAGAAACTTTGTATTGCATAGACGGTGCTTTACTTACAAAGTCCTCAGAATACAAAGGTCCTATTACGGATGTTTTCTACAAAGAAAACAGTTACACAACAACCATAAAACCAGTTACTTATAAATTGGATGGTGTTGTTTGTACAGAAATTGACCCTAAGTTGGACAATTATTATAAGAAAGACAATTCTTATTTCACAGAGCAACCAATTGATCTTGTACCAAACCAACCATATCCAAACGCAAGCTTCGATAATTTTAAGTTTGTATGTGATAATATCAAATTTGCTGATGATTTAAACCAGTTAACTGGTTATAAGAAACCTGCTTCAAGAGAGCTTAAAGTTACATTTTTCCCTGACTTAAATGGTGATGTGGTGGCTATTGATTATAAACACTACACACCCTCTTTTAAGAAAGGAGCTAAATTGTTACATAAACCTATTGTTTGGCATGTTAACAATGCAACTAATAAAGCCACGTATAAACCAAATACCTGGTGTATACGTTGTCTTTGGAGCACAAAACCAGTTGAAACATCAAATTCGTTTGATGTACTGAAGTCAGAGGACGCGCAGGGAATGGATAATCTTGCCTGCGAAGATCTAAAACCAGTCTCTGAAGAAGTAGTGGAAAATCCTACCATACAGAAAGACGTTCTTGAGTGTAATGTGAAAACTACCGAAGTTGTAGGAGACATTATACTTAAACCAGCAAATAATAGTTTAAAAATTACAGAAGAGGTTGGCCACACAGATCTAATGGCTGCTTATGTAGACAATTCTAGTCTTACTATTAAGAAACCTAATGAATTATCTAGAGTATTAGGTTTGAAAACCCTTGCTACTCATGGTTTAGCTGCTGTTAATAGTGTCCCTTGGGATACTATAGCTAATTATGCTAAGCCTTTTCTTAACAAAGTTGTTAGTACAACTACTAACATAGTTACACGGTGTTTAAACCGTGTTTGTACTAATTATATGCCTTATTTCTTTACTTTATTGCTACAATTGTGTACTTTTACTAGAAGTACAAATTCTAGAATTAAAGCATCTATGCCGACTACTATAGCAAAGAATACTGTTAAGAGTGTCGGTAAATTTTGTCTAGAGGCTTCATTTAATTATTTGAAGTCACCTAATTTTTCTAAACTGATAAATATTATAATTTGGTTTTTACTATTAAGTGTTTGCCTAGGTTCTTTAATCTACTCAACCGCTGCTTTAGGTGTTTTAATGTCTAATTTAGGCATGCCTTCTTACTGTACTGGTTACAGAGAAGGCTATTTGAACTCTACTAATGTCACTATTGCAACCTACTGTACTGGTTCTATACCTTGTAGTGTTTGTCTTAGTGGTTTAGATTCTTTAGACACCTATCCTTCTTTAGAAACTATACAAATTACCATTTCATCTTTTAAATGGGATTTAACTGCTTTTGGCTTAGTTGCAGAGTGGTTTTTGGCATATATTCTTTTCACTAGGTTTTTCTATGTACTTGGATTGGCTGCAATCATGCAATTGTTTTTCAGCTATTTTGCAGTACATTTTATTAGTAATTCTTGGCTTATGTGGTTAATAATTAATCTTGTACAAATGGCCCCGATTTCAGCTATGGTTAGAATGTACATCTTCTTTGCATCATTTTATTATGTATGGAAAAGTTATGTGCATGTTGTAGACGGTTGTAATTCATCAACTTGTATGATGTGTTACAAACGTAATAGAGCAACAAGAGTCGAATGTACAACTATTGTTAATGGTGTTAGAAGGTCCTTTTATGTCTATGCTAATGGAGGTAAAGGCTTTTGCAAACTACACAATTGGAATTGTGTTAATTGTGATACATTCTGTGCTGGTAGTACATTTATTAGTGATGAAGTTGCGAGAGACTTGTCACTACAGTTTAAAAGACCAATAAATCCTACTGACCAGTCTTCTTACATCGTTGATAGTGTTACAGTGAAGAATGGTTCCATCCATCTTTACTTTGATAAAGCTGGTCAAAAGACTTATGAAAGACATTCTCTCTCTCATTTTGTTAACTTAGACAACCTGAGAGCTAATAACACTAAAGGTTCATTGCCTATTAATGTTATAGTTTTTGATGGTAAATCAAAATGTGAAGAATCATCTGCAAAATCAGCGTCTGTTTACTACAGTCAGCTTATGTGTCAACCTATACTGTTACTAGATCAGGCATTAGTGTCTGATGTTGGTGATAGTGCGGAAGTTGCAGTTAAAATGTTTGATGCTTACGTTAATACGTTTTCATCAACTTTTAACGTACCAATGGAAAAACTCAAAACACTAGTTGCAACTGCAGAAGCTGAACTTGCAAAGAATGTGTCCTTAGACAATGTCTTATCTACTTTTATTTCAGCAGCTCGGCAAGGGTTTGTTGATTCAGATGTAGAAACTAAAGATGTTGTTGAATGTCTTAAATTGTCACATCAATCTGACATAGAAGTTACTGGCGATAGTTGTAATAACTATATGCTCACCTATAACAAAGTTGAAAACATGACACCCCGTGACCTTGGTGCTTGTATTGACTGTAGTGCGCGTCATATTAATGCGCAGGTAGCAAAAAGTCACAACATTGCTTTGATATGGAACGTTAAAGATTTCATGTCATTGTCTGAACAACTACGAAAACAAATACGTAGTGCTGCTAAAAAGAATAACTTACCTTTTAAGTTGACATGTGCAACTACTAGACAAGTTGTTAATGTTGTAACAACAAAGATAGCACTTAAGGGTGGTAAAATTGTTAATAATTGGTTGAAGCAGTTAATTAAAGTTACACTTGTGTTCCTTTTTGTTGCTGCTATTTTCTATTTAATAACACCTGTTCATGTCATGTCTAAACATACTGACTTTTCAAGTGAAATCATAGGATACAAGGCTATTGATGGTGGTGTCACTCGTGACATAGCATCTACAGATACTTGTTTTGCTAACAAACATGCTGATTTTGACACATGGTTTAGCCAGCGTGGTGGTAGTTATACTAATGACAAAGCTTGCCCATTGATTGCTGCAGTCATAACAAGAGAAGTGGGTTTTGTCGTGCCTGGTTTGCCTGGCACGATATTACGCACAACTAATGGTGACTTTTTGCATTTCTTACCTAGAGTTTTTAGTGCAGTTGGTAACATCTGTTACACACCATCAAAACTTATAGAGTACACTGACTTTGCAACATCAGCTTGTGTTTTGGCTGCTGAATGTACAATTTTTAAAGATGCTTCTGGTAAGCCAGTACCATATTGTTATGATACCAATGTACTAGAAGGTTCTGTTGCTTATGAAAGTTTACGCCCTGACACACGTTATGTGCTCATGGATGGCTCTATTATTCAATTTCCTAACACCTACCTTGAAGGTTCTGTTAGAGTGGTAACAACTTTTGATTCTGAGTACTGTAGGCACGGCACTTGTGAAAGATCAGAAGCTGGTGTTTGTGTATCTACTAGTGGTAGATGGGTACTTAACAATGATTATTACAGATCTTTACCAGGAGTTTTCTGTGGTGTAGATGCTGTAAATTTACTTACTAATATGTTTACACCACTAATTCAACCTATTGGTGCTTTGGACATATCAGCATCTATAGTAGCTGGTGGTATTGTAGCTATCGTAGTAACATGCCTTGCCTACTATTTTATGAGGTTTAGAAGAGCTTTTGGTGAATACAGTCATGTAGTTGCCTTTAATACTTTACTATTCCTTATGTCATTCACTGTACTCTGTTTAACACCAGTTTACTCATTCTTACCTGGTGTTTATTCTGTTATTTACTTGTACTTGACATTTTATCTTACTAATGATGTTTCTTTTTTAGCACATATTCAGTGGATGGTTATGTTCACACCTTTAGTACCTTTCTGGATAACAATTGCTTATATCATTTGTATTTCCACAAAGCATTTCTATTGGTTCTTTAGTAATTACCTAAAGAGACGTGTAGTCTTTAATGGTGTTTCCTTTAGTACTTTTGAAGAAGCTGCGCTGTGCACCTTTTTGTTAAATAAAGAAATGTATCTAAAGTTGCGTAGTGATGTGCTATTACCTCTTACGCAATATAATAGATACTTAGCTCTTTATAATAAGTACAAGTATTTTAGTGGAGCAATGGATACAACTAGCTACAGAGAAGCTGCTTGTTGTCATCTCGCAAAGGCTCTCAATGACTTCAGTAACTCAGGTTCTGATGTTCTTTACCAACCACCACAAACCTCTATCACCTCAGCTGTTTTGCAGAGTGGTTTTAGAAAAATGGCATTCCCATCTGGTAAAGTTGAGGGTTGTATGGTACAAGTAACTTGTGGTACAACTACACTTAACGGTCTTTGGCTTGATGACGTAGTTTACTGTCCAAGACATGTGATCTGCACCTCTGAAGACATGCTTAACCCTAATTATGAAGATTTACTCATTCGTAAGTCTAATCATAATTTCTTGGTACAGGCTGGTAATGTTCAACTCAGGGTTATTGGACATTCTATGCAAAATTGTGTACTTAAGCTTAAGGTTGATACAGCCAATCCTAAGACACCTAAGTATAAGTTTGTTCGCATTCAACCAGGACAGACTTTTTCAGTGTTAGCTTGTTACAATGGTTCACCATCTGGTGTTTACCAATGTGCTATGAGGCCCAATTTCACTATTAAGGGTTCATTCCTTAATGGTTCATGTGGTAGTGTTGGTTTTAACATAGATTATGACTGTGTCTCTTTTTGTTACATGCACCATATGGAATTACCAACTGGAGTTCATGCTGGCACAGACTTAGAAGGTAACTTTTATGGACCTTTTGTTGACAGGCAAACAGCACAAGCAGCTGGTACGGACACAACTATTACAGTTAATGTTTTAGCTTGGTTGTACGCTGCTGTTATAAATGGAGACAGGTGGTTTCTCAATCGATTTACCACAACTCTTAATGACTTTAACCTTGTGGCTATGAAGTACAATTATGAACCTCTAACACAAGACCATGTTGACATACTAGGACCTCTTTCTGCTCAAACTGGAATTGCCGTTTTAGATATGTGTGCTTCATTAAAAGAATTACTGCAAAATGGTATGAATGGACGTACCATATTGGGTAGTGCTTTATTAGAAGATGAATTTACACCTTTTGATGTTGTTAGACAATGCTCAGGTGTTACTTTCCAAAGTGCAGTGAAAAGAACAATCAAGGGTACACACCACTGGTTGTTACTCACAATTTTGACTTCACTTTTAGTTTTAGTCCAGAGTACTCAATGGTCTTTGTTCTTTTTTTTGTATGAAAATGCCTTTTTACCTTTTGCTATGGGTATTATTGCTATGTCTGCTTTTGCAATGATGTTTGTCAAACATAAGCATGCATTTCTCTGTTTGTTTTTGTTACCTTCTCTTGCCACTGTAGCTTATTTTAATATGGTCTATATGCCTGCTAGTTGGGTGATGCGTATTATGACATGGTTGGATATGGTTGATACTAGTTTGTCTGGTTTTAAGCTAAAAGACTGTGTTATGTATGCATCAGCTGTAGTGTTACTAATCCTTATGACAGCAAGAACTGTGTATGATGATGGTGCTAGGAGAGTGTGGACACTTATGAATGTCTTGACACTCGTTTATAAAGTTTATTATGGTAATGCTTTAGATCAAGCCATTTCCATGTGGGCTCTTATAATCTCTGTTACTTCTAACTACTCAGGTGTAGTTACAACTGTCATGTTTTTGGCCAGAGGTATTGTTTTTATGTGTGTTGAGTATTGCCCTATTTTCTTCATAACTGGTAATACACTTCAGTGTATAATGCTAGTTTATTGTTTCTTAGGCTATTTTTGTACTTGTTACTTTGGCCTCTTTTGTTTACTCAACCGCTACTTTAGACTGACTCTTGGTGTTTATGATTACTTAGTTTCTACACAGGAGTTTAGATATATGAATTCACAGGGACTACTCCCACCCAAGAATAGCATAGATGCCTTCAAACTCAACATTAAATTGTTGGGTGTTGGTGGCAAACCTTGTATCAAAGTAGCCACTGTACAGTCTAAAATGTCAGATGTAAAGTGCACATCAGTAGTCTTACTCTCAGTTTTGCAACAACTCAGAGTAGAATCATCATCTAAATTGTGGGCTCAATGTGTCCAGTTACACAATGACATTCTCTTAGCTAAAGATACTACTGAAGCCTTTGAAAAAATGGTTTCACTACTTTCTGTTTTGCTTTCCATGCAGGGTGCTGTAGACATAAACAAGCTTTGTGAAGAAATGCTGGACAACAGGGCAACCTTACAAGCTATAGCCTCAGAGTTTAGTTCCCTTCCATCATATGCAGCTTTTGCTACTGCTCAAGAAGCTTATGAGCAGGCTGTTGCTAATGGTGATTCTGAAGTTGTTCTTAAAAAGTTGAAGAAGTCTTTGAATGTGGCTAAATCTGAATTTGACCGTGATGCAGCCATGCAACGTAAGTTGGAAAAGATGGCTGATCAAGCTATGACCCAAATGTATAAACAGGCTAGATCTGAGGACAAGAGGGCAAAAGTTACTAGTGCTATGCAGACAATGCTTTTCACTATGCTTAGAAAGTTGGATAATGATGCACTCAACAACATTATCAACAATGCAAGAGATGGTTGTGTTCCCTTGAACATAATACCTCTTACAACAGCAGCCAAACTAATGGTTGTCATACCAGACTATAACACATATAAAAATACGTGTGATGGTACAACATTTACTTATGCATCAGCATTGTGGGAAATCCAACAGGTTGTAGATGCAGATAGTAAAATTGTTCAACTTAGTGAAATTAGTATGGACAATTCACCTAATTTAGCATGGCCTCTTATTGTAACAGCTTTAAGGGCCAATTCTGCTGTCAAATTACAGAATAATGAGCTTAGTCCTGTTGCACTACGACAGATGTCTTGTGCTGCCGGTACTACACAAACTGCTTGCACTGATGACAATGCGTTAGCTTACTACAACACAACAAAGGGAGGTAGGTTTGTACTTGCACTGTTATCCGATTTACAGGATTTGAAATGGGCTAGATTCCCTAAGAGTGATGGAACTGGTACTATCTATACAGAACTGGAACCACCTTGTAGGTTTGTTACAGACACACCTAAAGGTCCTAAAGTGAAGTATTTATACTTTATTAAAGGATTAAACAACCTAAATAGAGGTATGGTACTTGGTAGTTTAGCTGCCACAGTACGTCTACAAGCTGGTAATGCAACAGAAGTGCCTGCCAATTCAACTGTATTATCTTTCTGTGCTTTTGCTGTAGATGCTGCTAAAGCTTACAAAGATTATCTAGCTAGTGGGGGACAACCAATCACTAATTGTGTTAAGATGTTGTGTACACACACTGGTACTGGTCAGGCAATAACAGTTACACCGGAAGCCAATATGGATCAAGAATCCTTTGGTGGTGCATCGTGTTGTCTGTACTGCCGTTGCCACATAGATCATCCAAATCCTAAAGGATTTTGTGACTTAAAAGGTAAGTATGTACAAATACCTACAACTTGTGCTAATGACCCTGTGGGTTTTACACTTAAAAACACAGTCTGTACCGTCTGCGGTATGTGGAAAGGTTATGGCTGTAGTTGTGATCAACTCCGCGAACCCATGCTTCAGTCAGCTGATGCACAATCGTTTTTAAACGGGTTTGCGGTGTAAGTGCAGCCCGTCTTACACCGTGCGGCACAGGCACTAGTACTGATGTCGTATACAGGGCTTTTGACATCTACAATGATAAAGTAGCTGGTTTTGCTAAATTCCTAAAAACTAATTGTTGTCGCTTCCAAGAAAAGGACGAAGATGACAATTTAATTGATTCTTACTTTGTAGTTAAGAGACACACTTTCTCTAACTACCAACATGAAGAAACAATTTATAATTTACTTAAGGATTGTCCAGCTGTTGCTAAACATGACTTCTTTAAGTTTAGAATAGACGGTGACATGGTACCACATATATCACGTCAACGTCTTACTAAATACACAATGGCAGACCTCGTCTATGCTTTAAGGCATTTTGATGAAGGTAATTGTGACACATTAAAAGAAATACTTGTCACATACAATTGTTGTGATGATGATTATTTCAATAAAAAGGACTGGTATGATTTTGTAGAAAACCCAGATATATTACGCGTATACGCCAACTTAGGTGAACGTGTACGCCAAGCTTTGTTAAAAACAGTACAATTCTGTGATGCCATGCGAAATGCTGGTATTGTTGGTGTACTGACATTAGATAATCAAGATCTCAATGGTAACTGGTATGATTTCGGTGATTTCATACAAACCACGCCAGGTAGTGGAGTTCCTGTTGTAGATTCTTATTATTCATTGTTAATGCCTATATTAACCTTGACCAGGGCTTTAACTGCAGAGTCACATGTTGACACTGACTTAACAAAGCCTTACATTAAGTGGGATTTGTTAAAATATGACTTCACGGAAGAGAGGTTAAAACTCTTTGACCGTTATTTTAAATATTGGGATCAGACATACCACCCAAATTGTGTTAACTGTTTGGATGACAGATGCATTCTGCATTGTGCAAACTTTAATGTTTTATTCTCTACAGTGTTCCCACTTACAAGTTTTGGACCACTAGTGAGAAAAATATTTGTTGATGGTGTTCCATTTGTAGTTTCAACTGGATACCACTTCAGAGAGCTAGGTGTTGTACATAATCAGGATGTAAACTTACATAGCTCTAGACTTAGTTTTAAGGAATTACTTGTGTATGCTGCTGACCCTGCTATGCACGCTGCTTCTGGTAATCTATTACTAGATAAACGCACTACGTGCTTTTCAGTAGCTGCACTTACTAACAATGTTGCTTTTCAAACTGTCAAACCCGGTAATTTTAACAAAGACTTCTATGACTTTGCTGTGTCTAAGGGTTTCTTTAAGGAAGGAAGTTCTGTTGAATTAAAACACTTCTTCTTTGCTCAGGATGGTAATGCTGCTATCAGCGATTATGACTACTATCGTTATAATCTACCAACAATGTGTGATATCAGACAACTACTATTTGTAGTTGAAGTTGTTGATAAGTACTTTGATTGTTACGATGGTGGCTGTATTAATGCTAACCAAGTCATCGTCAACAACCTAGACAAATCAGCTGGTTTTCCATTTAATAAATGGGGTAAGGCTAGACTTTATTATGATTCAATGAGTTATGAGGATCAAGATGCACTTTTCGCATATACAAAACGTAATGTCATCCCTACTATAACTCAAATGAATCTTAAGTATGCCATTAGTGCAAAGAATAGAGCTCGCACCGTAGCTGGTGTCTCTATCTGTAGTACTATGACCAATAGACAGTTTCATCAAAAATTATTGAAATCAATAGCCGCCACTAGAGGAGCTACTGTAGTAATTGGAACAAGCAAATTCTATGGTGGTTGGCACAACATGTTAAAAACTGTTTATAGTGATGTAGAAAACCCTCACCTTATGGGTTGGGATTATCCTAAATGTGATAGAGCCATGCCTAACATGCTTAGAATTATGGCCTCACTTGTTCTTGCTCGCAAACATACAACGTGTTGTAGCTTGTCACACCGTTTCTATAGATTAGCTAATGAGTGTGCTCAAGTATTGAGTGAAATGGTCATGTGTGGCGGTTCACTATATGTTAAACCAGGTGGAACCTCATCAGGAGATGCCACAACTGCTTATGCTAATAGTGTTTTTAACATTTGTCAAGCTGTCACGGCCAATGTTAATGCACTTTTATCTACTGATGGTAACAAAATTGCCGATAAGTATGTCCGCAATTTACAACACAGACTTTATGAGTGTCTCTATAGAAATAGAGATGTTGACACAGACTTTGTGAATGAGTTTTACGCATATTTGCGTAAACATTTCTCAATGATGATACTCTCTGACGATGCTGTTGTGTGTTTCAATAGCACTTATGCATCTCAAGGTCTAGTGGCTAGCATAAAGAACTTTAAGTCAGTTCTTTATTATCAAAACAATGTTTTTATGTCTGAAGCAAAATGTTGGACTGAGACTGACCTTACTAAAGGACCTCATGAATTTTGCTCTCAACATACAATGCTAGTTAAACAGGGTGATGATTATGTGTACCTTCCTTACCCAGATCCATCAAGAATCCTAGGGGCCGGCTGTTTTGTAGATGATATCGTAAAAACAGATGGTACACTTATGATTGAACGGTTCGTGTCTTTAGCTATAGATGCTTACCCACTTACTAAACATCCTAATCAGGAGTATGCTGATGTCTTTCATTTGTACTTACAATACATAAGAAAGCTACATGATGAGTTAACAGGACACATGTTAGACATGTATTCTGTTATGCTTACTAATGATAACACTTCAAGGTATTGGGAACCTGAGTTTTATGAGGCTATGTACACACCGCATACAGTCTTACAGGCTGTTGGGGCTTGTGTTCTTTGCAATTCACAGACTTCATTAAGATGTGGTGCTTGCATACGTAGACCATTCTTATGTTGTAAATGCTGTTACGACCATGTCATATCAACATCACATAAATTAGTCTTGTCTGTTAATCCGTATGTTTGCAATGCTCCAGGTTGTGATGTCACAGATGTGACTCAACTTTACTTAGGAGGTATGAGCTATTATTGTAAATCACATAAACCACCCATTAGTTTTCCATTGTGTGCTAATGGACAAGTTTTTGGTTTATATAAAAATACATGTGTTGGTAGCGATAATGTTACTGACTTTAATGCAATTGCAACATGTGACTGGACAAATGCTGGTGATTACATTTTAGCTAACACCTGTACTGAAAGACTCAAGCTTTTTGCAGCAGAAACGCTCAAAGCTACTGAGGAGACATTTAAACTGTCTTATGGTATTGCTACTGTACGTGAAGTGCTGTCTGACAGAGAATTACATCTTTCATGGGAAGTTGGTAAACCTAGACCACCACTTAACCGAAATTATGTCTTTACTGGTTATCGTGTAACTAAAAACAGTAAAGTACAAATAGGAGAGTACACCTTTGAAAAAGGTGACTATGGTGATGCTGTTGTTTACCGAGGTACAACAACTTACAAATTAAATGTTGGTGATTATTTTGTGCTGACATCACATACAGTAATGCCATTAAGTGCACCTACACTAGTGCCACAAGAGCACTATGTTAGAATTACTGGCTTATACCCAACACTCAATATCTCAGATGAGTTTTCTAGCAATGTTGCAAATTATCAAAAGGTTGGTATGCAAAAGTATTCTACACTCCAGGGACCACCTGGTACTGGTAAGAGTCATTTTGCTATTGGCCTAGCTCTCTACTACCCTTCTGCTCGCATAGTGTATACAGCTTGCTCTCATGCCGCTGTTGATGCACTATGTGAGAAGGCATTAAAATATTTGCCTATAGATAAATGTAGTAGAATTATACCTGCACGTGCTCGTGTAGAGTGTTTTGATAAATTCAAAGTGAATTCAACATTAGAACAGTATGTCTTTTGTACTGTAAATGCATTGCCTGAGACGACAGCAGATATAGTTGTCTTTGATGAAATTTCAATGGCCACAAATTATGATTTGAGTGTTGTCAATGCCAGATTACGTGCTAAGCACTATGTGTACATTGGCGACCCTGCTCAATTACCTGCACCACGCACATTGCTAACTAAGGGCACACTAGAACCAGAATATTTCAATTCAGTGTGTAGACTTATGAAAACTATAGGTCCAGACATGTTCCTCGGAACTTGTCGGCGTTGTCCTGCTGAAATTGTTGACACTGTGAGTGCTTTGGTTTATGATAATAAGCTTAAAGCACATAAAGACAAATCAGCTCAATGCTTTAAAATGTTTTATAAGGGTGTTATCACGCATGATGTTTCATCTGCAATTAACAGGCCACAAATAGGCGTGGTAAGAGAATTCCTTACACGTAACCCTGCTTGGAGAAAAGCTGTCTTTATTTCACCTTATAATTCACAGAATGCTGTAGCCTCAAAGATTTTGGGACTACCAACTCAAACTGTTGATTCATCACAGGGCTCAGAATATGACTATGTCATATTCACTCAAACCACTGAAACAGCTCACTCTTGTAATGTAAACAGATTTAATGTTGCTATTACCAGAGCAAAAGTAGGCATACTTTGCATAATGTCTGATAGAGACCTTTATGACAAGTTGCAATTTACAAGTCTTGAAATTCCACGTAGGAATGTGGCAACTTTACAAGCTGAAAATGTAACAGGACTCTTTAAAGATTGTAGTAAGGTAATCACTGGGTTACATCCTACACAGGCACCTACACACCTCAGTGTTGACACTAAATTCAAAACTGAAGGTTTATGTGTTGACATACCTGGCATACCTAAGGACATGACCTATAGAAGACTCATCTCTATGATGGGTTTTAAAATGAATTATCAAGTTAATGGTTACCCTAACATGTTTATCACCCGCGAAGAAGCTATAAGACATGTACGTGCATGGATTGGCTTCGATGTCGAGGGGTGTCATGCTACTAGAGAAGCTGTTGGTACCAATTTACCTTTACAGCTAGGTTTTTCTACAGGTGTTAACCTAGTTGCTGTACCTACAGGTTATGTTGATACACCTAATAATACAGATTTTTCCAGAGTTAGTGCTAAACCACCGCCTGGAGATCAATTTAAACACCTCATACCACTTATGTACAAAGGACTTCCTTGGAATGTAGTGCGTATAAAGATTGTACAAATGTTAAGTGACACACTTAAAAATCTCTCTGACAGAGTCGTATTTGTCTTATGGGCACATGGCTTTGAGTTGACATCTATGAAGTATTTTGTGAAAATAGGACCTGAGCGCACCTGTTGTCTATGTGATAGACGTGCCACATGCTTTTCCACTGCTTCAGACACTTATGCCTGTTGGCATCATTCTATTGGATTTGATTACGTCTATAATCCGTTTATGATTGATGTTCAACAATGGGGTTTTACAGGTAACCTACAAAGCAACCATGATCTGTATTGTCAAGTCCATGGTAATGCACATGTAGCTAGTTGTGATGCAATCATGACTAGGTGTTTAGCTGTCCACGAGTGCTTTGTTAAGCGTGTTGACTGGACTATTGAATATCCTATAATTGGTGATGAACTGAAGATTAATGCGGCTTGTAGAAAGGTTCAACACATGGTTGTTAAAGCTGCATTATTAGCAGACAAATTCCCAGTTCTTCACGACATTGGTAACCCTAAAGCTATTAAGTGTGTACCTCAAGCTGATGTAGAATGGAAGTTCTATGATGCACAGCCTTGTAGTGACAAAGCTTATAAAATAGAAGAATTATTCTATTCTTATGCCACACATTCTGACAAATTCACAGATGGTGTATGCCTATTTTGGAATTGCAATGTCGATAGATATCCTGCTAATTCCATTGTTTGTAGATTTGACACTAGAGTGCTATCTAACCTTAACTTGCCTGGTTGTGATGGTGGCAGTTTGTATGTAAATAAACATGCATTCCACACACCAGCTTTTGATAAAAGTGCTTTTGTTAATTTAAAACAATTACCATTTTTCTATTACTCTGACAGTCCATGTGAGTCTCATGGAAAACAAGTAGTGTCAGATATAGATTATGTACCACTAAAGTCTGCTACGTGTATAACACGTTGCAATTTAGGTGGTGCTGTCTGTAGACATCATGCTAATGAGTACAGATTGTATCTCGATGCTTATAACATGATGATCTCAGCTGGCTTTAGCTTGTGGGTTTACAAACAATTTGATACTTATAACCTCTGGAACACTTTTACAAGACTTCAGAGTTTAGAAAATGTGGCTTTTAATGTTGTAAATAAGGGACACTTTGATGGACAACAGGGTGAAGTACCAGTTTCTATCATTAATAACACTGTTTACACAAAAGTTGATGGTGTTGATGTAGAATTGTTTGAAAATAAAACAACATTACCTGTTAATGTAGCATTTGAGCTTTGGGCTAAGCGCAACATTAAACCAGTACCAGAGGTGAAAATACTCAATAATTTGGGTGTGGACATTGCTGCTAATACTGTGATCTGGGACTACAAAAGAGATGCTCCAGCACATATATCTACTATTGGTGTTTGTTCTATGACTGACATAGCCAAGAAACCAACTGAAACGATTTGTGCACCACTCACTGTCTTTTTTGATGGTAGAGTTGATGGTCAAGTAGACTTATTTAGAAATGCCCGTAATGGTGTTCTTATTACAGAAGGTAGTGTTAAAGGTTTACAACCATCTGTAGGTCCCAAACAAGCTAGTCTTAATGGAGTCACATTAATTGGAGAAGCCGTAAAAACACAGTTCAATTATTATAAGAAAGTTGATGGTGTTGTCCAACAATTACCTGAAACTTACTTTACTCAGAGTAGAAATTTACAAGAATTTAAACCCAGGAGTCAAATGGAAATTGATTTCTTAGAATTAGCTATGGATGAATTCATTGAACGGTATAAATTAGAAGGCTATGCCTTCGAACATATCGTTTATGGAGATTTTAGTCATAGTCAGTTAGGTGGTTTACATCTACTGATTGGACTAGCTAAACGTTTTAAGGAATCACCTTTTGAATTAGAAGATTTTATTCCTATGGACAGTACAGTTAAAAACTATTTCATAACAGATGCGCAAACAGGTTCATCTAAGTGTGTGTGTTCTGTTATTGATTTATTACTTGATGATTTTGTTGAAATAATAAAATCCCAAGATTTATCTGTAGTTTCTAAGGTTGTCAAAGTGACTATTGACTATACAGAAATTTCATTTATGCTTTGGTGTAAAGATGGCCATGTAGAAACATTTTACCCAAAATTACAATCTAGTCAAGCGTGGCAACCGGGTGTTGCTATGCCTAATCTTTACAAAATGCAAAGAATGCTATTAGAAAAGTGTGACCTTCAAAATTATGGTGATAGTGCAACATTACCTAAAGGCATAATGATGAATGTCGCAAAATATACTCAACTGTGTCAATATTTAAACACATTAACATTAGCTGTACCCTATAATATGAGAGTTATACATTTTGGTGCTGGTTCTGATAAAGGAGTTGCACCAGGTACAGCTGTTTTAAGACAGTGGTTGCCTACGGGTACGCTGCTTGTCGATTCAGATCTTAATGACTTTGTCTCTGATGCAGATTCAACTTTGATTGGTGATTGTGCAACTGTACATACAGCTAATAAATGGGATCTCATTATTAGTGATATGTACGACCCTAAGACTAAAAATGTTACAAAAGAAAATGACTCTAAAGAGGGTTTTTTCACTTACATTTGTGGGTTTATACAACAAAAGCTAGCTCTTGGAGGTTCCGTGGCTATAAAGATAACAGAACATTCTTGGAATGCTGATCTTTATAAGCTCATGGGACACTTCGCATGGTGGACAGCCTTTGTTACTAATGTGAATGCGTCATCATCTGAAGCATTTTTAATTGGATGTAATTATCTTGGCAAACCACGCGAACAAATAGATGGTTATGTCATGCATGCAAATTACATATTTTGGAGGAATACAAATCCAATTCAGTTGTCTTCCTATTCTTTATTTGACATGAGTAAATTTCCCCTTAAATTAAGGGGTACTGCTGTTATGTCTTTAAAAGAAGGTCAAATCAATGATATGATTTTATCTCTTCTTAGTAAAGGTAGACTTATAATTAGAGAAAACAACAGAGTTGTTATTTCTAGTGATGTTCTTGTTAACAACTAAACGAACAATGTTTGTTTTTCTTGTTTTATTGCCACTAGTCTCTAGTCAGTGTGTTAATCTTACAACCAGAACTCAATTACCCCCTGCATACACTAATTCTTTCACACGTGGTGTTTATTACCCTGACAAAGTTTTCAGATCCTCAGTTTTACATTCAACTCAGGACTTGTTCTTACCTTTCTTTTCCAATGTTACTTGGTTCCATGCTATACATGTCTCTGGGACCAATGGTACTAAGAGGTTTGATAACCCTGTCCTACCATTTAATGATGGTGTTTATTTTGCTTCCACTGAGAAGTCTAACATAATAAGAGGCTGGATTTTTGGTACTACTTTAGATTCGAAGACCCAGTCCCTACTTATTGTTAATAACGCTACTAATGTTGTTATTAAAGTCTGTGAATTTCAATTTTGTAATGATCCATTTTTGGGTGTTTATTACCACAAAAACAACAAAAGTTGGATGGAAAGTGAGTTCAGAGTTTATTCTAGTGCGAATAATTGCACTTTTGAATATGTCTCTCAGCCTTTTCTTATGGACCTTGAAGGAAAACAGGGTAATTTCAAAAATCTTAGGGAATTTGTGTTTAAGAATATTGATGGTTATTTTAAAATATATTCTAAGCACACGCCTATTAATTTAGTGCGTGATCTCCCTCAGGGTTTTTCGGCTTTAGAACCATTGGTAGATTTGCCAATAGGTATTAACATCACTAGGTTTCAAACTTTACTTGCTTTACATAGAAGTTATTTGACTCCTGGTGATTCTTCTTCAGGTTGGACAGCTGGTGCTGCAGCTTATTATGTGGGTTATCTTCAACCTAGGACTTTTCTATTAAAATATAATGAAAATGGAACCATTACAGATGCTGTAGACTGTGCACTTGACCCTCTCTCAGAAACAAAGTGTACGTTGAAATCCTTCACTGTAGAAAAAGGAATCTATCAAACTTCTAACTTTAGAGTCCAACCAACAGAATCTATTGTTAGATTTCCTAATATTACAAACTTGTGCCCTTTTGGTGAAGTTTTTAACGCCACCAGATTTGCATCTGTTTATGCTTGGAACAGGAAGAGAATCAGCAACTGTGTTGCTGATTATTCTGTCCTATATAATTCCGCATCATTTTCCACTTTTAAGTGTTATGGAGTGTCTCCTACTAAATTAAATGATCTCTGCTTTACTAATGTCTATGCAGATTCATTTGTAATTAGAGGTGATGAAGTCAGACAAATCGCTCCAGGGCAAACTGGAAAGATTGCTGATTATAATTATAAATTACCAGATGATTTTACAGGCTGCGTTATAGCTTGGAATTCTAACAATCTTGATTCTAAGGTTGGTGGTAATTATAATTACCTGTATAGATTGTTTAGGAAGTCTAATCTCAAACCTTTTGAGAGAGATATTTCAACTGAAATCTATCAGGCCGGTAGCACACCTTGTAATGGTGTTGAAGGTTTTAATTGTTACTTTCCTTTACAATCATATGGTTTCCAACCCACTAATGGTGTTGGTTACCAACCATACAGAGTAGTAGTACTTTCTTTTGAACTTCTACATGCACCAGCAACTGTTTGTGGACCTAAAAAGTCTACTAATTTGGTTAAAAACAAATGTGTCAATTTCAACTTCAATGGTTTAACAGGCACAGGTGTTCTTACTGAGTCTAACAAAAAGTTTCTGCCTTTCCAACAATTTGGCAGAGACATTGCTGACACTACTGATGCTGTCCGTGATCCACAGACACTTGAGATTCTTGACATTACACCATGTTCTTTTGGTGGTGTCAGTGTTATAACACCAGGAACAAATACTTCTAACCAGGTTGCTGTTCTTTATCAGGGTGTTAACTGCACAGAAGTCCCTGTTGCTATTCATGCAGATCAACTTACTCCTACTTGGCGTGTTTATTCTACAGGTTCTAATGTTTTTCAAACACGTGCAGGCTGTTTAATAGGGGCTGAACATGTCAACAACTCATATGAGTGTGACATACCCATTGGTGCAGGTATATGCGCTAGTTATCAGACTCAGACTAATTCTCCTCGGCGGGCACGTAGTGTAGCTAGTCAATCCATCATTGCCTACACTATGTCACTTGGTGCAGAAAATTCAGTTGCTTACTCTAATAACTCTATTGCCATACCCACAAATTTTACTATTAGTGTTACCACAGAAATTCTACCAGTGTCTATGACCAAGACATCAGTAGATTGTACAATGTACATTTGTGGTGATTCAACTGAATGCAGCAATCTTTTGTTGCAATATGGCAGTTTTTGTACACAATTAAACCGTGCTTTAACTGGAATAGCTGTTGAACAAGACAAAAACACCCAAGAAGTTTTTGCACAAGTCAAACAAATTTACAAAACACCACCAATTAAAGATTTTGGTGGTTTTAATTTTTCACAAATATTACCAGATCCATCAAAACCAAGCAAGAGGTCATTTATTGAAGATCTACTTTTCAACAAAGTGACACTTGCAGATGCTGGCTTCATCAAACAATATGGTGATTGCCTTGGTGATATTGCTGCTAGAGACCTCATTTGTGCACAAAAGTTTAACGGCCTTACTGTTTTGCCACCTTTGCTCACAGATGAAATGATTGCTCAATACACTTCTGCACTGTTAGCGGGTACAATCACTTCTGGTTGGACCTTTGGTGCAGGTGCTGCATTACAAATACCATTTGCTATGCAAATGGCTTATAGGTTTAATGGTATTGGAGTTACACAGAATGTTCTCTATGAGAACCAAAAATTGATTGCCAACCAATTTAATAGTGCTATTGGCAAAATTCAAGACTCACTTTCTTCCACAGCAAGTGCACTTGGAAAACTTCAAGATGTGGTCAACCAAAATGCACAAGCTTTAAACACGCTTGTTAAACAACTTAGCTCCAATTTTGGTGCAATTTCAAGTGTTTTAAATGATATCCTTTCACGTCTTGACAAAGTTGAGGCTGAAGTGCAAATTGATAGGTTGATCACAGGCAGACTTCAAAGTTTGCAGACATATGTGACTCAACAATTAATTAGAGCTGCAGAAATCAGAGCTTCTGCTAATCTTGCTGCTACTAAAATGTCAGAGTGTGTACTTGGACAATCAAAAAGAGTTGATTTTTGTGGAAAGGGCTATCATCTTATGTCCTTCCCTCAGTCAGCACCTCATGGTGTAGTCTTCTTGCATGTGACTTATGTCCCTGCACAAGAAAAGAACTTCACAACTGCTCCTGCCATTTGTCATGATGGAAAAGCACACTTTCCTCGTGAAGGTGTCTTTGTTTCAAATGGCACACACTGGTTTGTAACACAAAGGAATTTTTATGAACCACAAATCATTACTACAGACAACACATTTGTGTCTGGTAACTGTGATGTTGTAATAGGAATTGTCAACAACACAGTTTATGATCCTTTGCAACCTGAATTAGACTCATTCAAGGAGGAGTTAGATAAATATTTTAAGAATCATACATCACCAGATGTTGATTTAGGTGACATCTCTGGCATTAATGCTTCAGTTGTAAACATTCAAAAAGAAATTGACCGCCTCAATGAGGTTGCCAAGAATTTAAATGAATCTCTCATCGATCTCCAAGAACTTGGAAAGTATGAGCAGTATATAAAATGGCCATGGTACATTTGGCTAGGTTTTATAGCTGGCTTGATTGCCATAGTAATGGTGACAATTATGCTTTGCTGTATGACCAGTTGCTGTAGTTGTCTCAAGGGCTGTTGTTCTTGTGGATCCTGCTGCAAATTTGATGAAGACGACTCTGAGCCAGTGCTCAAAGGAGTCAAATTACATTACACATAAACGAACTTATGGATTTGTTTATGAGAATCTTCACAATTGGAACTGTAACTTTGAAGCAAGGTGAAATCAAGGATGCTACTCCTTCAGATTTTGTTCGCGCTACTGCAACGATACCGATACAAGCCTCACTCCCTTTCGGATGGCTTATTGTTGGCGTTGCACTTCTTGCTGTTTTTCATAGCGCTTCCAAAATCATAACCCTCAAAAAGAGATGGCAACTAGCACTCTCCAAGGGTGTTCACTTTGTTTGCAACTTGCTGTTGTTGTTTGTAACAGTTTACTCACACCTTTTGCTCGTTGCTGCTGGCCTTGAAGCCCCTTTTCTCTATCTTTATGCTTTAGTCTACTTCTTGCAGAGTATAAACTTTGTAAGAATAATAATGAGGCTTTGGCTTTGCTGGAAATGCCGTTCCAAAAACCCATTACTTTATGATGCCAACTATTTTCTTTGCTGGCATACTAATTGTTACGACTATTGTATACCTTACAATAGTGTAACTTCTTCAATTGTCATTACTTCAGGTGATGGCACAACAAGTCCTATTTCTGAACATGACTACCAGATTGGTGGTTATACTGAAAAATGGGAATCTGGAGTAAAAGACTGTGTTGTATTACACAGTTACTTCACTTCAGACTATTACCAGCTGTACTCAACTCAATTGAGTACAGACACTGGTGTTGAACATGTTACCTTCTTCATCTACAATAAAATTGTTGATGAGCCTGAAGAACATGTCCAAATTCACACAATCGACGGTTCATCCGGAGTTGTTAATCCAGTAATGGAACCAATTTATGATGAACCGACGACGACTACTAGCGTGCCTTTGTAAGCACAAGCTGATGAGTACGAACTTATGTACTCATTCGTTTCGGAAGAGACAGGTACGTTAATAGTTAATAGCGTACTTCTTTTTCTTGCTTTCGTGGTATTCTTGCTAGTTACACTAGCCATCCTTACTGCGCTTCGATTGTGTGCGTACTGCTGCAATATTGTTAACGTGAGTCTTGTAAAACCTTCTTTTTACGTTTACTCTCGTGTTAAAAATCTGAATTCTTCTAGAGTTCCTGATCTTCTGGTCTAAACGAACTAAATATTATATTAGTTTTTCTGTTTGGAACTTTAATTTTAGCCATGGCAGATTCCAACGGTACTATTACCGTTGAAGAGCTTAAAAAGCTCCTTGAACAATGGAACCTAGTAATAGGTTTCCTATTCCTTACATGGATTTGTCTTCTACAATTTGCCTATGCCAACAGGAATAGGTTTTTGTATATAATTAAGTTAATTTTCCTCTGGCTGTTATGGCCAGTAACTTTAGCTTGTTTTGTGCTTGCTGCTGTTTACAGAATAAATTGGATCACCGGTGGAATTGCTATCGCAATGGCTTGTCTTGTAGGCTTGATGTGGCTCAGCTACTTCATTGCTTCTTTCAGACTGTTTGCGCGTACGCGTTCCATGTGGTCATTCAATCCAGAAACTAACATTCTTCTCAACGTGCCACTCCATGGCACTATTCTGACCAGACCGCTTCTAGAAAGTGAACTCGTAATCGGAGCTGTGATCCTTCGTGGACATCTTCGTATTGCTGGACACCATCTAGGACGCTGTGACATCAAGGACCTGCCTAAAGAAATCACTGTTGCTACATCACGAACGCTTTCTTATTACAAATTGGGAGCTTCGCAGCGTGTAGCAGGTGACTCAGGTTTTGCTGCATACAGTCGCTACAGGATTGGCAACTATAAATTAAACACAGACCATTCCAGTAGCAGTGACAATATTGCTTTGCTTGTACAGTAAGTGACAACAGATGTTTCATCTCGTTGACTTTCAGGTTACTATAGCAGAGATATTACTAATTATTATGAGGACTTTTAAAGTTTCCATTTGGAATCTTGATTACATCATAAACCTCATAATTAAAAATTTATCTAAGTCACTAACTGAGAATAAATATTCTCAATTAGATGAAGAGCAACCAATGGAGATTGATTAAACGAACATGAAAATTATTCTTTTCTTGGCACTGATAACACTCGCTACTTGTGAGCTTTATCACTACCAAGAGTGTGTTAGAGGTACAACAGTACTTTTAAAAGAACCTTGCTCTTCTGGAACATACGAGGGCAATTCACCATTTCATCCTCTAGCTGATAACAAATTTGCACTGACTTGCTTTAGCACTCAATTTGCTTTTGCTTGTCCTGACGGCGTAAAACACGTCTATCAGTTACGTGCCAGATCAGTTTCACCTAAACTGTTCATCAGACAAGAGGAAGTTCAAGAACTTTACTCTCCAATTTTTCTTATTGTTGCGGCAATAGTGTTTATAACACTTTGCTTCACACTCAAAAGAAAGACAGAATGATTGAACTTTCATTAATTGACTTCTATTTGTGCTTTTTAGCCTTTCTGCTATTCCTTGTTTTAATTATGCTTATTATCTTTTGGTTCTCACTTGAACTGCAAGATCATAATGAAACTTGTCACGCCTAAACGAACATGAAATTTCTTGTTTTCTTAGGAATCATCACAACTGTAGCTGCATTTCACCAAGAATGTAGTTTACAGTCATGTACTCAACATCAACCATATGTAGTTGATGACCCGTGTCCTATTCACTTCTATTCTAAATGGTATATTAGAGTAGGAGCTAGAAAATCAGCACCTTTAATTGAATTGTGCGTGGATGAGGCTGGTTCTAAATCACCCATTCAGTACATCGATATCGGTAATTATACAGTTTCCTGTTTACCTTTTACAATTAATTGCCAGGAACCTAAATTGGGTAGTCTTGTAGTGCGTTGTTCGTTCTATGAAGACTTTTTAGAGTATCATGACGTTCGTGTTGTTTTAGATTTCATCTAAACGAACAAACTAAAATGTCTGATAATGGACCCCAAAATCAGCGAAATGCACCCCGCATTACGTTTGGTGGACCCTCAGATTCAACTGGCAGTAACCAGAATGGAGAACGCAGTGGGGCGCGATCAAAACAACGTCGGCCCCAAGGTTTACCCAATAATACTGCGTCTTGGTTCACCGCTCTCACTCAACATGGCAAGGAAGACCTTAAATTCCCTCGAGGACAAGGCGTTCCAATTAACACCAATAGCAGTCCAGATGACCAAATTGGCTACTACCGAAGAGCTACCAGACGAATTCGTGGTGGTGACGGTAAAATGAAAGATCTCAGTCCAAGATGGTATTTCTACTACCTAGGAACTGGGCCAGAAGCTGGACTTCCCTATGGTGCTAACAAAGACGGCATCATATGGGTTGCAACTGAGGGAGCCTTGAATACACCAAAAGATCACATTGGCACCCGCAATCCTGCTAACAATGCTGCAATCGTGCTACAACTTCCTCAAGGAACAACATTGCCAAAAGGCTTCTACGCAGAAGGGAGCAGAGGCGGCAGTCAAGCCTCTTCTCGTTCCTCATCACGTAGTCGCAACAGTTCAAGAAATTCAACTCCAGGCAGCAGTAGGGGAACTTCTCCTGCTAGAATGGCTGGCAATGGCGGTGATGCTGCTCTTGCTTTGCTGCTGCTTGACAGATTGAACCAGCTTGAGAGCAAAATGTCTGGTAAAGGCCAACAACAACAAGGCCAAACTGTCACTAAGAAATCTGCTGCTGAGGCTTCTAAGAAGCCTCGGCAAAAACGTACTGCCACTAAAGCATACAATGTAACACAAGCTTTCGGCAGACGTGGTCCAGAACAAACCCAAGGAAATTTTGGGGACCAGGAACTAATCAGACAAGGAACTGATTACAAACATTGGCCGCAAATTGCACAATTTGCCCCCAGCGCTTCAGCGTTCTTCGGAATGTCGCGCATTGGCATGGAAGTCACACCTTCGGGAACGTGGTTGACCTACACAGGTGCCATCAAATTGGATGACAAAGATCCAAATTTCAAAGATCAAGTCATTTTGCTGAATAAGCATATTGACGCATACAAAACATTCCCACCAACAGAGCCTAAAAAGGACAAAAAGAAGAAGGCTGATGAAACTCAAGCCTTACCGCAGAGACAGAAGAAACAGCAAACTGTGACTCTTCTTCCTGCTGCAGATTTGGATGATTTCTCCAAACAATTGCAACAATCCATGAGCAGTGCTGACTCAACTCAGGCCTAAACTCATGCAGACCACACAAGGCAGATGGGCTATATAAACGTTTTCGCTTTTCCGTTTACGATATATAGTCTACTCTTGTGCAGAATGAATTCTCGTAACTACATAGCACAAGTAGATGTAGTTAACTTTAATCTCACATAGCAATCTTTAATCAGTGTGTAACATTAGGGAGGACTTGAAAGAGCCACCACATTTTCACCGAGGCCACGCGGAGTACGATCGAGTGTACAGTGAACAATGCTAGGGAGAGCTGCCTATATGGAAGAGCCCTAATGTGTAAAATTAATTTTAGTAGTGCTATCCCCATGTGATTTTAATAGCTTCTTAGG
```

Como ves, hay un pequeño problema, y es que tenemos un caracter `\n` de más al principio del fichero y uno de menos al final. 
Lo primero podemos solucionarlo con `tail`, diciéndole que coja a partir de la segunda línea (`-n +2`). Lo segundo lo arreglamos con `sed`, diciéndole que añada una línea vacía después de la última línea. Si consultamos el manual (sección "Addresses"), `$` sirve para indicarle a `sed` que queremos que opere en la última linea (no confundir con el símbolo de "fin de línea" de las expresiones regulares). La línea vacía se indica con el caracter `\` seguido de _nada_, que representa el caracter vacío. Finalmente, salvamos el resultado a un fichero que tendrá el formato deseado:

```
abenito@cpg3:~/sesion-iv/fasta$ sed -E 's/^(>.+)/$\1$/' covid-samples.fasta | tr -d "\n" | tr '$' '\n' | tail -n +2 | sed '$ a \' > covid-samples-unilinea.fasta
```

Nota: Recuerda que en POSIX, todos los ficheros de textos [deberían terminar en `\n`](http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap03.html#tag_03_206). Así que ya sabes, añade un salto de línea a todos tus ficheros de texto si no quieres tener problemas con ellos en UNIX ;)

Finalmente, comprobamos que el fichero de salida contiene el número de líneas esperado, 8 (4 nombres de secuencia + 4 secuencias).

```
abenito@cpg3:~/sesion-iv/fasta$ wc -l covid-samples-unilinea.fasta
8 covid-samples-unilinea.fasta
```

## Ejercicio 4
En la sección 3.1., convertimos la cadena `chr1:3214482-3216968` a un formato tabular con `sed`. Sin embargo, existen otras maneras en las que podríamos haber obtenido el mismo resultado final. ¿Se te ocurren algunas? Recuerda que puedes usar el flag `g`, o puedes encadenar distintas llamadas a `sed` con tuberías si ves que meterlo todo en una única expresión regular se te antoja complicado. 

### Respuesta ejercicio 4

Te planteo aquí un par de ejemplos que consiguen lo mismo que la orden original del guión de la práctica, que usaba grupos de captura para formatear la salida:

```
abenito@cpg3:~/sesion-iv$ echo "chr1:3214482-3216968" | sed -E 's/^(chr[^:]+):([0-9]+)-([0-9]+)/\1\t\2\t\3/'
chr1	3214482	3216968
```

Pero no es necesario usar grupos de captura para algo tan sencillo: el enfoque más obvio es primero sustituir el caracter `:` por un tabulador y después hacer lo propio con el caracter `-`:

```
abenito@cpg3:~/sesion-iv$ echo "chr1:3214482-3216968" | sed 's/:/\t/' | sed 's/-/\t/'
chr1	3214482	3216968
```

También podemos juntar ambas en una sola llamada a `sed` definiendo la clase que incluye los delimitadores `:` y `-`. Pero aquí lo más importante es emplear el modificador global `g` para que `sed` efectúe varias sustituciones por línea:

```
abenito@cpg3:~/sesion-iv$ echo "chr1:3214482-3216968" | sed 's/[:-]/\t/g'
chr1	3214482	3216968
```

Como todo lo que queremos sustituir por tabuladores son caracteres de "no palabra", también podemos usar la clase correspondiente `\W` ("w" mayúscula):

```
abenito@cpg3:~/sesion-iv$ echo "chr1:3214482-3216968" | sed 's/\W/\t/g'
chr1	3214482	3216968
```

O usando clases POSIX, negando la clase de caracteres alfanuméricos `[:alnum:]`:

```
abenito@cpg3:~/sesion-iv$ echo "chr1:3214482-3216968" | sed 's/[^[:alnum:]]/\t/g'
chr1	3214482	3216968
```

## Ejercicio 5

Crea un pipeline que implemente lo siguiente (pruébalo con `covid-samples.fasta`). 
1. Identifique y cuente todos aquellos nucleótidos que no sean {A,C,G,T}
2. Los elimine (crear fichero intermedio con `tee`)
3. Para cada secuencia en el stream resultante del paso anterior, cree un mapa de frecuencias de cada nucleótido e imprima un resumen. 
4. Usando una variable previamente definida en la shell, `PORCIONES`, calcule el mapa de frecuencias partiendo cada secuencia en `$PORCIONES` trozos. Imprímelo y además, guárdalo a un CSV. 

### Respuesta ejercicio 5
El objetivo de este ejercicio era intentar "obligaros" a diseñar un pipeline complejo de manera **modular** (recuerda: ["Divide y Vencerás"](https://es.wikipedia.org/wiki/Algoritmo_divide_y_vencer%C3%A1s)). No pasa nada si no diste con la manera de juntar todas las partes en un sólo pipeline: la idea era que **creases primero los módulos por separado** y luego los **intentases juntar**, prestando atención al formato de los datos que cada parte tendría que recibir/sacar. En este solución te muestro el proceso que he seguido yo para dar con la solución y espero que te sirva para implementar tus propios pipelines complejos en el futuro.

Para resaltar el caracter modular del pipeline, y aunque no lo pida el enunciado, voy a ir creando ficheros intermedios que usaremos para diseñar y depurar la siguiente parte del pipeline. Finalmente, ensamblaremos todas las partes creadas en un único pipeline que no emplee estos ficheros intermedios.

####1. Pasos 1 y 2: Identificar y eliminar caracteres "extraños":
Para ilustrar el uso de `awk`, he optado por usar el fichero creado en el ejercicio 3, `covid-samples-unilinea.fasta`. Consideraremos por tanto, que el primer paso de nuestro pipeline incluye ejecutar las instrucciones necesarias para convertir el fichero fasta multilínea a otro unilínea. En esta solución, empleo directamente el fichero unilínea por claridad, pero conectar los dos pipelines es trivial.

En la primera parte del ejercicio se nos pide:

1. Contar e identificar símbolos en las secuencias no incluidos en {A,C,G,T}. La salida de este conteo la guardaremos a un fichero. 
2. Eliminar los caracteres extraños de cada secuencia y generar un nuevo fasta. El fasta se guardará a un fichero y también se pasará al siguiente módulo de nuestro pipeline.

#####1.1. Identificar y contar símbolos extraños
Nuestro primer módulo o subpipeline se encargará de contar caracteres extraños en las secuencias de nuestro fasta de entrada, salvando los resultados a un fichero llamado `no_actg_informe.txt`. Esta operación a su vez se compondrá de 3 pasos :

1. Eliminar las cabeceras del fasta: `grep -v "^>" covid-samples-unilinea.fasta`
2. Extraer los símbolos restantes que **no sean** ni "A", ni "C", ni "G" ni "T": `grep -o "[^ACGT]"`
3. Ordenarlos, contar, y extraer las ocurrencias únicas de cada símbolo, salvando el resultado a un fichero: `sort | uniq -c | sort -nr > no_actg_informe.txt`

Poniéndolo todo junto, nos queda:

`grep -v "^>" covid-samples-unilinea.fasta | grep -o "[^ACGT]" | sort | uniq -c | sort -nr > no_actg_informe.txt`

Y si lo ejecutamos:

```
abenito@cpg3:~/sesion-iv/fasta$ grep -v "^>" covid-samples-unilinea.fasta | grep -o "[^ACGT]" | sort | uniq -c | sort -nr > no_actg_informe.txt
abenito@cpg3:~/sesion-iv/fasta$ cat no_actg_informe.txt
   2602 N
      3 S
      3 M
      2 W
      2 R
      2 K
      1 Y
      1 _
```

#####1.2. Eliminar caracteres extraños
Ahora usaremos la misma expresión regular del apartado interior para sustituir con `sed` todas las ocurrencias de caracteres extraños en las líneas de secuencia. Esto es lo mismo que decirle a `sed` que sustituya todas las apariciones de `[^ACTG]` en las líneas que **no sean** de nombre de secuencia (es decir, en aquellas que no empiecen por el caracter `>`). ¿Cómo podemos hacer que `sed` trabaje sólo en ciertas líneas? De nuevo, la explicación podemos encontrarla en la sección del manual "Addresses" que explica esto. En concreto, nos fijamos en dos partes de esta sección. En una dice:

```
/regexp/
      Match lines matching the regular expression regexp.
```

Así que no sólo vamos a poder pasar números de línea antes de la acción, sino que además también podemos especificar una expresión regular para seleccionar las líneas en las que queremos efectuar la edición. Ahora, para seleccionar las líneas de secuencia del fasta, podemos usar o bien la expresión regular "no empieza por `>`" (`^[^>]`), o bien, si seguimos leyendo el manual...

```
After  the address (or address-range), and before the command, a !  may be inserted, which specifies that the command shall only be executed if the address (or address-
       range) does not match.
```

...vemos que podemos insertar un símbolo de exclamación `!` antes de la acción de sustituir `s` para negar selección. Además, añadiremos el modificador global `g` para que sed haga tantas sustituciones como pueda por línea (recuerda que cada línea contiene toda la secuencia, aunque funcionaría igual para multilínea) Por lo tanto, podemos escribir:

`sed '/^[^>]/s/[^ACGT]//g' covid-samples-unilinea.fasta > covid_samples-unilinea_limpio.fasta`

o bien:

`sed '/^>/!s/[^ACGT]//g' covid-samples-unilinea.fasta > covid_samples-unilinea_limpio.fasta`

produciendo el mismo resultado. 

#####1.3. Unir 1.1 y 1.2
Para concluir con la implementación del primer módulo, sólo nos resta juntar las órdenes de los puntos 1.1 y 1.2. Como hemos explicado antes, tanto el pipeline 1.1. como el 1.2 reciben los mismos datos de entrada (`covid-samples-unilinea.fasta`), produciendo cada uno de ellos una salida distinta. Esto implica que tenemos que bifurcar nuestro flujo de datos de entrada para pasárselo a cada uno por separado, produciendo dos resultados distintos. Como ya sabemos, la orden de la shell que sirve este propósito es `tee`. 

En vez de sacar una de las salida de `tee` directamente a un fichero, lo que haremos será pasarle a todo el pipeline 1.1. los datos usando una redirección (`>`). A su vez, el pipeline 1.1 procesará los datos y los guardará a un fichero como hemos explicado. La otra salida de `tee` se la pasaremos al pipeline 1.2., que a su vez llamará otra vez `tee`, que bifurcará su entrada a un fichero fasta "limpio" y a un pipe que se comunicará con el siguiente módulo encargado de generar los mapas de frecuencias.

```
abenito@cpg3:~/sesion-iv/fasta$ cat covid-samples-unilinea.fasta | tee >(grep -v "^>" | grep -o "[^ACGT]" | sort | uniq -c > no_actg_informe.txt) | sed '/>/!s/[^ACGT]//g' | tee covid_samples-unilinea_limpio.fasta | less
```

####2. Pasos 3 y 4: crear mapas de frecuencias e informes
En este punto nos centraremos en la tarea de crear un mapa de frecuencias para cada una de las secuencias "limpias" del fasta que generamos en el paso anterior. Debido a que esta tarea requiere un poco más de "inteligencia", vamos a usar `awk` para implementarla ya que éste nos va a permitir emplear un nivel de expresividad suficente para el fin que queremos conseguir.

Comenzaremos primero por crear un csv y un informe de acuerdo al punto 3 del enunciado. Después continuaremos al punto 4, y realizaremos las modificaciones necesarias para que `awk` recupere el valor de la variable `PORCIONES` y genere el mapa de frecuencias para cada uno de los trozos que resulten de partir cada secuencia en `$PORCIONES` trozos iguales.

#####2.1. Paso 3: Mapa de frecuencias simple
Para obtener el mapa de frecuencias de nucleótidos de cada secuencia contenida en `covid_samples-unilinea_limpio.fasta`, vamos a crear un código `awk` que emplee arrays asociativos (diccionarios) para ir incrementeando la cuenta de cada nucleótido según lo vaya encontrando.

Ya que `awk` trabaja con líneas y nosotros queremos contar caracteres, es mucho más intuitivo sacar cada caracter de cada secuencia a una línea (como hicimos en el pipeline 1.1 con `grep -o "[^ACGT]"`) y procesar esa entrada que no dejarla como está (una secuencia por línea) y emplear las [funciones de manipulación de cadenas](https://www.gnu.org/software/gawk/manual/html_node/String-Functions.html) de `awk`.

Como hicimos en el pipeline 1.1 con `grep -o "[^ACGT]"`, vamos primero a sacar cada caracter a una línea, lo cual nos va a permitir crear un código `awk` más sencillo. Sin embargo, y a diferencia de lo que ocurría en el punto 1.1, ahora estaremos tratando con el fichero fasta entero (no solo sus secuencias). Por lo tanto, vamos a emplear `sed` para partir las líneas de secuencia en caracteres, diciéndole como hicimos antes que opere sólo en las líneas que no comiencen por `>`.

Para sacar los caracteres a sus respectivas líneas, usaremos un grupo de captura `([ACTG])` y una referencia hacia atrás a este grupo para insertar un salto de línea detrás de cada caracter que encuentre en cada una de las líneas de entrada. 

```
abenito@cpg3:~/sesion-iv/fasta$ sed -E '/^>/!s/([ACTG])/\1\n/g' covid_samples-unilinea_limpio.fasta | head -n10
>MW186669.1 |Severe acute respiratory syndrome coronavirus 2 isolate SARS-CoV-2/human/EGY/Cairo-sample 19 MOH/2020, complete genome
G
T
T
T
A
T
A
C
C
```

Además, como también queremos calcular las frecuencias relativas de cada nucleótido, vamos a necesitar conocer la longitud de cada secuencia. Podríamos emplear un contador en `awk` que se fuese incrementando por cada caracter (línea) leída, o usando la variable interna `NR`. Pero si reparamos en lo que se nos pide hacer en el punto 4, es mejor precalcularla antes de pasarle los datos a `awk`. ¿Por qué? Porque nos va a ser mucho más sencillo partir las secuencias sabiendo de antemano cuál es la longitud total de cada una: tal como hemos planteado la solución, cada línea va a contener un único carácter. Por lo tanto, `awk` no va a saber cuántos caracteres quedan por procesar en la secuencia actual y no sabríamos saber en tiempo de ejecución donde termina una parte y empieza la siguiente. Este problema se puede solucionar fácilmente añadiendo una línea con la longitud de la secuencia justo debajo de la que contiene el nombre de la misma. Para ello, usaremos la función `length` de `awk` que, según el manual, va a imprimir la longitud de todo el registro `$0` si no se le pasan argumentos:

```
length([s]) 	Return  the  length  of the string s, or the length of $0 if s is not supplied.  
				As a non-standard extension, with an array argument, length() returns the number of elements in the array.
```


El script es el siguiente:


```
abenito@cpg3:~/sesion-iv/fasta$ awk '$0 ~ "^>" {print $0}; $0 ~ "^[ACTG]"{ print length "\n" $0 }' covid_samples-unilinea_limpio.fasta | head -n3
>MW186669.1 |Severe acute respiratory syndrome coronavirus 2 isolate SARS-CoV-2/human/EGY/Cairo-sample 19 MOH/2020, complete genome
29853
GTTTATACCTTCCCAGGTAACAAACCAACCAACTTTCGATCTCTTGTAGATCTGTTCTCTAAACGAACTTTAAAATCTGTGTGGCTGTCACTCGGCTGCATGCTTAGTGCACTCACGCAGTATAATTAATAACTAATTACTGTCGTTGACAGGACACGAGTAACTCGTCTATCTTCTGCAGGCTGCTTACGGTTTCGTCCGTGTTGCAGCCGATCATCAGCACATCTAGGTTTTGTCCGGGTGT...
```

Como se puede observar, el script añade una línea con la longitud de la secuencia en caracteres (29853) que va inmediatamente debajo.
Ahora ya sí, esto se lo pasamos a `sed` para que parta las líneas con secuencias en caracteres:

```
abenito@cpg3:~/sesion-iv/fasta$ awk '$0 ~ "^>" {print $0}; $0 ~ "^[ACTG]"{ print length "\n" $0 }' covid_samples-unilinea_limpio.fasta | sed -E '/^>/!s/([ACTG])/\1\n/g' | head
>MW186669.1 |Severe acute respiratory syndrome coronavirus 2 isolate SARS-CoV-2/human/EGY/Cairo-sample 19 MOH/2020, complete genome
29853
G
T
T
T
A
T
A
C
```

Una vez que ya tenemos el fichero en el formato deseado, sólo es cuestión de crear un script en `awk` que cuente los caracteres que vaya encontrando en cada línea. Para que se entienda mejor lo he movido a su propio archivo (`genera_informe.awk`) que reproduzco aquí debajo (también puedes encontrarlo entre los ficheros de este repositorio).

```
#!/usr/bin/awk -f

#Bloque 0: A ejecutar antes de empezar el procesamiento
BEGIN {
    indice_s = -1 #En esta variable llevaremos la cuenta de la secuencia que vamos procesando.
};

#Bloque 1: A ejecutar en líneas con nombre de secuencia
$0 ~ "^>" { #Cada vez que el primer caracter sea ">" significa que vamos a empezar a procesar una nueva secuencia.
    indice_s += 1
    #Aquí inicializamos las variables necesarias para procesar los daots
    nombres_secs[indice_s] = $0 #Nombre de la secuencia
    nombres_cortos_secs[indice_s] = $1 #Nombre corto de la secuencia
    longitudes_secs[indice_s] = 0 #Longitud total de la secuencia
    contador[indice_s]["A"] = 0 #Mapa de frecuencias para los 4 nucleótidos que se piden
    contador[indice_s]["C"] = 0
    contador[indice_s]["T"] = 0
    contador[indice_s]["G"] = 0
};

#Bloque 2: A ejecutar en líneas con longitud de secuencia
$0 ~ "^[[:digit:]]" {
    longitudes_secs[indice_s] = $1
};

#Bloque 3: A ejecutar en cada línea de secuencia
$0 ~ "^[ACTG]" {
    contador[indice_s][$1] += 1 #Incrementamos la cuenta del nucleótido en cuestión
};

#Bloque 4: A ejecutar al final del procesamiento: Imprime el resumen y salva los datos a un fichero
END {
    #Creamos la cabecera del informe en formato CSV
    print "nombre_secuencia,nucleotido,frecuencia_absoluta,frecuencia_relativa" > "informe.csv"
    for (sec_i in contador) { #Recorremos cada secuencia
        print nombres_secs[sec_i] #Imprimimos el nombre de la secuencia
        for (nucl in contador[sec_i]) { #Para cada contador de nucleótido imprimos frecuencia absoluta y relativa
            print nucl "\t" contador[sec_i][nucl] " (" 100*contador[sec_i][nucl]/longitudes_secs[sec_i]"%)"
            #salvamos cada dato a una nueva línea del CSV
            print nombres_cortos_secs[sec_i] "," nucl "," contador[sec_i][nucl] "," 100*contador[sec_i][nucl]/longitudes_secs[sec_i] >> "informe.csv"
        }
    }
};
```

Como ves, la lógica del script es muy sencilla y su implementación se parece mucho a la de Python. Además, yo he optado por generar el informe directamente desde awk usando los operadores redirección `>` y `>>` (sección "I/O Statements" del manual de `awk`). Aunque podríamos optar también por coger la salida de `awk` y formatearla un poco antes de volcarla a un fichero desde la shell siguiendo el método habitual, es mejor y más rápido hacerlo de esta manera.


#####2.2. Paso 4: Mapa de frecuencias usando la variable de la shell PORCIONES
Para terminar con este ejercicio, vamos a adaptar nuestra solución para que acepte una variable definida en la shell, `PORCIONES`, que nos dirá cuántos mapas de frecuencias (uno por cada porción) tendremos que crear. El primer reto de este punto consiste en saber cómo pasarle variables definidas en la shell a `awk`. Aunque, como hemos visto, `awk` usa variables, éstas son sólo internas y no pueden ser accedidas desde fuera del script (imagínate si no qué lío!). Análogamente, un script `awk` _por defecto_ tampoco puede leer variables definidas fuera de él. He aquí una prueba:

```
abenito@cpg3:~/sesion-iv/fasta$ PORCIONES=4
abenito@cpg3:~/sesion-iv/fasta$ awk 'BEGIN { print "Esto funciona?? La variable PORCIONES vale " PORCIONES "??"}' covid_samples-unilinea_limpio.fasta
Esto funciona?? La variable PORCIONES vale ??
```

Al imprimir la variable PORCIONES, que no está definida, no obtenemos el resultado esperado. Sin embargo, al principio de la página del manual se explica la manera correcta de asignar una variable al invocar a `awk` desde la línea de comandos:

```
-v var=val
       --assign var=val
              Assign the value val to the variable var, before execution of the program begins.  Such variable values are available to the BEGIN rule of an AWK program.
```

Entonces, si invocamos awk con la opción `-v`, podemos asignar el valor de la variable de la shell `$PORCIONES` a una variable interna de awk llamada `PORCIONES` (aunque podríamos llamarla como quisiéramos):

```
abenito@cpg3:~/sesion-iv/fasta$ awk -v PORCIONES=$PORCIONES 'BEGIN { print "Esto funciona?? La variable PORCIONES vale " PORCIONES "??"}' covid_samples-unilinea_limpio.fasta
Esto funciona?? La variable PORCIONES vale 4??
```

Ahora ya podemos modificar nuestro script (`genera_informe_seqs.awk`) para que utilice esta variable. Como hacíamos en la asignatura de Python, creamos un mapa de frecuencias por cada secuencia y porción. La única diferencia es que aquí no hay que recorrer las líneas...(ya lo hace `awk` por nosotras!). Además, guardamos dónde termina cada porción de cada secuencia para cambiar de mapa de frecuencias cuando toque. Finalmente, imprimimos los resultados y añadimos una nueva columna a nuestro CSV. Te dejo aquí el código comentado:

```
#!/usr/bin/awk -f

#Bloque 0: A ejecutar antes de empezar el procesamiento
BEGIN {
    indice_s = -1 #En esta variable llevaremos la cuenta de la secuencia que vamos procesando.
    if (!porciones || porciones < 2 || porciones > 10) { #Comprobamos que la variable porciones contiene lo que esperamos.
        print "Lo siento, la variable porciones ha de estar definida entre 2 y 10"
        exit 1
    }
};

#Bloque 1: A ejecutar en líneas con nombre de secuencia
$0 ~ "^>" { #Cada vez que el primer caracter sea ">" significa que vamos a empezar a procesar una nueva secuencia.
    indice_s += 1
    indice_p = 0 #Aquí guardaremos la porción por la que vamos
    caracteres_porcion=0 #Y aquí los caracteres que llevamos procesados
    #Aquí inicializamos las variables necesarias para procesar los daots
    nombres_secs[indice_s] = $0 #Nombre de la secuencia
    nombres_cortos_secs[indice_s] = $1 #Nombre corto de la secuencia
    longitudes_secs[indice_s] = 0 #Longitud total de la secuencia
    for (porcion_i=0; porcion_i < porciones; porcion_i++) { #Creamos un mapa de frecuencias por porción y por secuencia
        contador[indice_s][porcion_i]["A"] = 0 #Mapa de frecuencias para los 4 nucleótidos que se piden
        contador[indice_s][porcion_i]["C"] = 0
        contador[indice_s][porcion_i]["T"] = 0
        contador[indice_s][porcion_i]["G"] = 0
    }
};

#Bloque 2: A ejecutar en líneas con longitud de secuencia
$0 ~ "^[[:digit:]]" {
    longitudes_secs[indice_s] = $1
    longitud_porcion = int(1.0 * $1 / porciones + 0.5) #solución tarea 2 asignatura Python
    for (porcion_i=0; porcion_i < porciones; porcion_i++) { #Creamos un mapa de frecuencias por porción y por secuencia
        if (porcion_i == porciones - 1)
            fin_porciones[indice_s][porcion_i] = $1 #Aquí guardados dónde termina cada porción
        else
            fin_porciones[indice_s][porcion_i] = longitud_porcion * (porcion_i + 1)

        if (porcion_i == 0)
            longitud_porciones[indice_s][porcion_i] = longitud_porcion #Y aquí la longitud de cada una (para calcular las frecuencias relativas).
        else
            longitud_porciones[indice_s][porcion_i] = fin_porciones[indice_s][porcion_i] - fin_porciones[indice_s][porcion_i-1]
    }
};

#Bloque 3: A ejecutar en cada línea de secuencia
$0 ~ "^[ACTG]" {
    caracteres_porcion += 1
    contador[indice_s][indice_p][$1] += 1 #Incrementamos la cuenta del nucleótido en cuestión
    if (caracteres_porcion == fin_porciones[indice_s][indice_p])
        indice_p+=1
};

#Bloque 4: A ejecutar al final del procesamiento: Imprime el resumen y salva los datos a un fichero
END {
    #Creamos la cabecera del informe en formato CSV
    print "nombre_secuencia,porcion,nucleotido,frecuencia_absoluta,frecuencia_relativa" > "informe.csv"
    #print "nombre_secuencia,nucleotido,frecuencia_absoluta,frecuencia_relativa" > "informe.csv"
    for (sec_i in contador) { #Recorremos cada secuencia
        print nombres_secs[sec_i] #Imprimimos el nombre de la secuencia
        for (porcion_i in contador[sec_i]) { #Recorremos cada porcion
            print "Porción " porcion_i+1 #Imprimimos el índice
            for (nucl in contador[sec_i][porcion_i]) { #Para cada contador de nucleótido imprimimos frecuencia absoluta y relativa
                print nucl "\t" contador[sec_i][porcion_i][nucl] " (" 100*contador[sec_i][porcion_i][nucl]/longitud_porciones[sec_i][porcion_i]"%)"
                print nombres_cortos_secs[sec_i] "," porcion_i ";" nucl "," contador[sec_i][porcion_i][nucl] ";" 100*contador[sec_i][porcion_i][nucl]/longitud_porciones[sec_i][porcion_i] >> "informe.csv"
            }
        }
    }
};
```

Como ves, el script es un poco largo y si bien es cierto que cuando empecemos a llegar a estas longitudes de código lo suyo sería empezar a pensar en moverse a `Python`, nos sirve para demostrar el poder de `awk` como lenguaje de programación y procesamiento de textos.

####3. Todo junto

Si juntamos los pipelines que hemos ido creando en cada uno de los pasos al final nos queda: 

**informes simples:**

```
abenito@cpg3:~/sesion-iv/fasta$ cat covid-samples-unilinea.fasta | tee >(grep -v "^>" | grep -o "[^ACGT]" | sort | uniq -c > no_actg_informe.txt) | sed '/>/!s/[^ACGT]//g' | tee covid_samples-unilinea_limpio.fasta | awk '$0 ~ "^>" {print $0}; $0 ~ "^[ACTG]"{ print length "\n" $0 }' | sed -E '/^>/!s/([ACTG])/\1\n/g' | awk -f genera_informe.awk
```

**informes por porciones:**

```
abenito@cpg3:~/sesion-iv/fasta$ cat covid-samples-unilinea.fasta | tee >(grep -v "^>" | grep -o "[^ACGT]" | sort | uniq -c > no_actg_informe.txt) | sed '/>/!s/[^ACGT]//g' | tee covid_samples-unilinea_limpio.fasta | awk '$0 ~ "^>" {print $0}; $0 ~ "^[ACTG]"{ print length "\n" $0 }' | sed -E '/^>/!s/([ACTG])/\1\n/g' | awk -v porciones=$PORCIONES -f genera_informe_porciones.awk
```

**NOTA**

Este era un ejercicio para nota! Si no pudiste dar con la solución en el plazo de entrega y quieres terminar de implementarla, o si simplemente quieres mejorarla, te animo a que lo hagas! Aquí van algunas ideas:

- ¿Podrías implementar tu propia solución sin usar un fasta unilínea? 
- ¿Se te ocurre cómo mejorar el pipeline usando los conceptos vistos en la sesión 5 (p.ej., bucles en Bash)? 

Actualiza tu repositorio con lo que hagas (envíame un correo avisándome para que lo mire) para poder ganarte algún puntillo extra y poder optar a la máxima nota (tienes hasta el día 9 de Abril para hacerlo).
