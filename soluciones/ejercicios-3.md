# Sesión III - Redireccionamiento, filtros y pipes

Herramientas computacionales para bioinformática: UNIX, expresiones regulares y shell script

Edita esta plantilla en formato markdown [Guía aquí](https://guides.github.com/features/mastering-markdown/) como se pide en el guión. 
Cuando hayas acabado, haz un commit de tus cambios y súbelos al repositorio antes de la fecha de entrega señalada. 

======================================


## Ejercicio 1
`sort -R` (random) desordena las líneas de un fichero. Prueba a desordenar el fichero `gene-2.bed` y crea un nuevo fichero llamado `gene-2-desordenado.bed`.

Trata ahora de ordenar este fichero de acuerdo a los siguientes criterios: 
1. Sin cortar los elementos
2. En orden descendente
3. Usando a la vez la tercera y la segunda columna (en este orden de prioridad). Consulta el manual para ver la opción -k. 

### Respuesta ejercicio 1
Lo primero es crear el fichero desordenado con la opción que se indica:

```
abenito@cpg3:~/sesion-iii/genes$ sort -R gene-2.bed > gene-2-desordenado.bed
```

- 1. Para ordenar el fichero simplemente usaremos la orden `sort -n` para que lo ordene numéricamente. De esta manera, ordenará el fichero por el valor de sus columnas de izquierda a derecha. 

```
abenito@cpg3:~/sesion-iii/genes$ sort -n gene-2-desordenado.bed
1	6206197	6206270	GENE00000025907
1	6206227	6206270	GENE00000025907
1	6222341	6228319	GENE00000025907
1	6223599	6223745	GENE00000025907
1	6227940	6228049	GENE00000025907
1	6227940	6228049	GENE00000025907
1	6227940	6228049	GENE00000025907
1	6229959	6230073	GENE00000025907
1	6229959	6230073	GENE00000025907
1	6229959	6230073	GENE00000025907
1	6230133	6230191	GENE00000025907
1	6233961	6234087	GENE00000025907
1	6233961	6234087	GENE00000025907
1	6233961	6234087	GENE00000025907
1	6234229	6234311	GENE00000025907
1	6234229	6234399	GENE00000025907
1	6234229	6234399	GENE00000025907
1	6238262	6238384	GENE00000025907
1	6239952	6240378	GENE00000025907
```

- 2. Para ordenar en orden descendente basta con añadir la opción -r

```
abenito@cpg3:~/sesion-iii/genes$ sort -nr gene-2-desordenado.bed
1	6239952	6240378	GENE00000025907
1	6238262	6238384	GENE00000025907
1	6234229	6234399	GENE00000025907
1	6234229	6234399	GENE00000025907
1	6234229	6234311	GENE00000025907
1	6233961	6234087	GENE00000025907
1	6233961	6234087	GENE00000025907
1	6233961	6234087	GENE00000025907
1	6230133	6230191	GENE00000025907
1	6229959	6230073	GENE00000025907
1	6229959	6230073	GENE00000025907
1	6229959	6230073	GENE00000025907
1	6227940	6228049	GENE00000025907
1	6227940	6228049	GENE00000025907
1	6227940	6228049	GENE00000025907
1	6223599	6223745	GENE00000025907
1	6222341	6228319	GENE00000025907
1	6206227	6206270	GENE00000025907
1	6206197	6206270	GENE00000025907
```

- 3. Este tiene un poco más de truco. Como hemos visto en los dos ejercicios anteriores, `grep` ordena por columnas de izquierda a derecha. Si queremos modificar este comportamiento, podemos usar la opción `-k KEYDEF` para especificar el orden. Si queremos que ordene primero por la segunda y por la tercera columna, hemos de especificárselo como rangos según la ayuda:
```
KEYDEF  is  F[.C][OPTS][,F[.C][OPTS]]  for  start and stop position, where F is a field number and C a character position in the field; both are origin 1, and the stop position defaults to the line's
       end.  If neither -t nor -b is in effect, characters in a field are counted from the beginning of the preceding whitespace.  OPTS is one or more single-letter  ordering  options  [bdfgiMhnRrV],  which
       override global ordering options for that key.  If no key is given, use the entire line as the key.  Use --debug to diagnose incorrect key usage.
```

Además, podemos añadir el flag `n` para que ordene numéricamente:


```
abenito@cpg3:~/sesion-iii/genes$ sort -k3,3n -k2,2n gene-2-desordenado.bed
1	6206197	6206270	GENE00000025907
1	6206227	6206270	GENE00000025907
1	6223599	6223745	GENE00000025907
1	6227940	6228049	GENE00000025907
1	6227940	6228049	GENE00000025907
1	6227940	6228049	GENE00000025907
1	6222341	6228319	GENE00000025907
1	6229959	6230073	GENE00000025907
1	6229959	6230073	GENE00000025907
1	6229959	6230073	GENE00000025907
1	6230133	6230191	GENE00000025907
1	6233961	6234087	GENE00000025907
1	6233961	6234087	GENE00000025907
1	6233961	6234087	GENE00000025907
1	6234229	6234311	GENE00000025907
1	6234229	6234399	GENE00000025907
1	6234229	6234399	GENE00000025907
1	6238262	6238384	GENE00000025907
1	6239952	6240378	GENE00000025907
```



## Ejercicio 2

Cuáles son y cuántos tipos distintos de "features" hay en `Drosophila_melanogaster.BDGP6.28.102.gtf` y en `Homo_sapiens.GRCh38.102.gtf.gz`? Nota: para trabajar con ficheros .gunzip sin descomprimir puedes usar `zcat`.

### Respuesta ejercicio 2
Echando un vistazo rápido a ambos ficheros, vemos que el dato que queremos extraer se encuentra en la tercera columna:

```
abenito@cpg3:~/sesion-iii/gtfs$ head -n5 Drosophila_melanogaster.BDGP6.28.102.gtf | column -t
#!genome-build            BDGP6.28
#!genome-version          BDGP6.28
#!genome-build-accession  GCA_000001215.4
3R                        FlyBase          gene        567076  2532932  .  +  .  gene_id  "FBgn0267431";  gene_name      "Myo81F";       gene_source  "FlyBase";  gene_biotype  "protein_coding";
3R                        FlyBase          transcript  567076  2532932  .  +  .  gene_id  "FBgn0267431";  transcript_id  "FBtr0392909";  gene_name    "Myo81F";   gene_source   "FlyBase";         gene_biotype  "protein_coding";  transcript_source  "FlyBase";  transcript_biotype  "protein_coding";
```

En el caso del fichero comprimido, tenemos que usar `zcat` y "pipear" su salida a `head` para ver sus contenidos:

```
abenito@cpg3:~/sesion-iii/gtfs$ zcat Homo_sapiens.GRCh38.102.gtf.gz | head -n7 | column -t
#!genome-build            GRCh38.p13
#!genome-version          GRCh38
#!genome-date             2013-12
#!genome-build-accession  NCBI:GCA_000001405.28
#!genebuild-last-updated  2020-09
1                         havana                 gene        11869  14409  .  +  .  gene_id  "ENSG00000223972";  gene_version  "5";  gene_name      "DDX11L1";          gene_source         "havana";  gene_biotype  "transcribed_unprocessed_pseudogene";
1                         havana                 transcript  11869  14409  .  +  .  gene_id  "ENSG00000223972";  gene_version  "5";  transcript_id  "ENST00000456328";  transcript_version  "2";       gene_name     "DDX11L1";                             gene_source  "havana";  gene_biotype  "transcribed_unprocessed_pseudogene";  transcript_name  "DDX11L1-202";  transcript_source  "havana";  transcript_biotype  "processed_transcript";  tag  "basic";  transcript_support_level  "1";
```

Para extraer dicha columna, tendremos que emplear la orden `cut`. Sin embargo, es necesario antes eliminar las líneas de cabecera, lo cual haremos con `tail`:

```
abenito@cpg3:~/sesion-iii/gtfs$ tail -n+4 Drosophila_melanogaster.BDGP6.28.102.gtf | head -n5 | column -t
3R  FlyBase  gene        567076  2532932  .  +  .  gene_id  "FBgn0267431";  gene_name      "Myo81F";       gene_source  "FlyBase";  gene_biotype  "protein_coding";
3R  FlyBase  transcript  567076  2532932  .  +  .  gene_id  "FBgn0267431";  transcript_id  "FBtr0392909";  gene_name    "Myo81F";   gene_source   "FlyBase";         gene_biotype  "protein_coding";  transcript_source  "FlyBase";         transcript_biotype  "protein_coding";
3R  FlyBase  exon        567076  567268   .  +  .  gene_id  "FBgn0267431";  transcript_id  "FBtr0392909";  exon_number  "1";        gene_name     "Myo81F";          gene_source   "FlyBase";         gene_biotype       "protein_coding";  transcript_source   "FlyBase";         transcript_biotype  "protein_coding";  exon_id     "FBtr0392909-E1";
3R  FlyBase  exon        835376  835491   .  +  .  gene_id  "FBgn0267431";  transcript_id  "FBtr0392909";  exon_number  "2";        gene_name     "Myo81F";          gene_source   "FlyBase";         gene_biotype       "protein_coding";  transcript_source   "FlyBase";         transcript_biotype  "protein_coding";  exon_id     "FBtr0392909-E2";
3R  FlyBase  CDS         835378  835491   .  +  0  gene_id  "FBgn0267431";  transcript_id  "FBtr0392909";  exon_number  "2";        gene_name     "Myo81F";          gene_source   "FlyBase";         gene_biotype       "protein_coding";  transcript_source   "FlyBase";         transcript_biotype  "protein_coding";  protein_id  "FBpp0352251";
```

`Homo_sapiens.GRCh38.102.gtf.gz` cuenta con 2 líneas más en su cabecera. Por lo tanto, sumamos dos posiciones a `tail`:

```
abenito@cpg3:~/sesion-iii/gtfs$ zcat Homo_sapiens.GRCh38.102.gtf.gz | tail -n+6 | head -n5 | column -t
1  havana  gene        11869  14409  .  +  .  gene_id  "ENSG00000223972";  gene_version  "5";  gene_name      "DDX11L1";          gene_source         "havana";  gene_biotype  "transcribed_unprocessed_pseudogene";
1  havana  transcript  11869  14409  .  +  .  gene_id  "ENSG00000223972";  gene_version  "5";  transcript_id  "ENST00000456328";  transcript_version  "2";       gene_name     "DDX11L1";                             gene_source  "havana";   gene_biotype  "transcribed_unprocessed_pseudogene";  transcript_name  "DDX11L1-202";                         transcript_source  "havana";       transcript_biotype  "processed_transcript";  tag                 "basic";                 transcript_support_level  "1";
1  havana  exon        11869  12227  .  +  .  gene_id  "ENSG00000223972";  gene_version  "5";  transcript_id  "ENST00000456328";  transcript_version  "2";       exon_number   "1";                                   gene_name    "DDX11L1";  gene_source   "havana";                              gene_biotype     "transcribed_unprocessed_pseudogene";  transcript_name    "DDX11L1-202";  transcript_source   "havana";                transcript_biotype  "processed_transcript";  exon_id                   "ENSE00002234944";  exon_version  "1";  tag  "basic";  transcript_support_level  "1";
1  havana  exon        12613  12721  .  +  .  gene_id  "ENSG00000223972";  gene_version  "5";  transcript_id  "ENST00000456328";  transcript_version  "2";       exon_number   "2";                                   gene_name    "DDX11L1";  gene_source   "havana";                              gene_biotype     "transcribed_unprocessed_pseudogene";  transcript_name    "DDX11L1-202";  transcript_source   "havana";                transcript_biotype  "processed_transcript";  exon_id                   "ENSE00003582793";  exon_version  "1";  tag  "basic";  transcript_support_level  "1";
1  havana  exon        13221  14409  .  +  .  gene_id  "ENSG00000223972";  gene_version  "5";  transcript_id  "ENST00000456328";  transcript_version  "2";       exon_number   "3";                                   gene_name    "DDX11L1";  gene_source   "havana";                              gene_biotype     "transcribed_unprocessed_pseudogene";  transcript_name    "DDX11L1-202";  transcript_source   "havana";                transcript_biotype  "processed_transcript";  exon_id                   "ENSE00002312635";  exon_version  "1";  tag  "basic";  transcript_support_level  "1";
```

Ahora que ya tenemos ambos ficheros limpios de líneas de cabecera, podemos usar `cut` en la tercera columna. La salida de cut la ordenaremos con `sort` para poder contar las líneas (features) que son únicas con `uniq -c`. Para mejorar la comprensibilidad de los resultados, podemos volver a ordenar numéricamente (`-n`) con `sort` para que los resultados salgan listados de mayor a menor (`-r`):

```
abenito@cpg3:~/sesion-iii/gtfs$ tail -n+4 Drosophila_melanogaster.BDGP6.28.102.gtf | cut -f3 | sort | uniq -c | sort -nr
 188169 exon
 161508 CDS
  46462 five_prime_utr
  34920 transcript
  33453 three_prime_utr
  30595 start_codon
  30590 stop_codon
  17807 gene
      4 Selenocysteine

abenito@cpg3:~/sesion-iii/gtfs$ zcat Homo_sapiens.GRCh38.102.gtf.gz | tail -n+6 | cut -f3 | sort | uniq -c | sort -nr
1429266 exon
 789946 CDS
 232024 transcript
 167723 three_prime_utr
 157872 five_prime_utr
  90054 start_codon
  82918 stop_codon
  60675 gene
    117 Selenocysteine
```
 

## Ejercicio 3

Recuerdas `covid-samples.fasta`? Localízalo en tu HOME, y extrae, usando un pipeline, los nombres de las secuencias contenidas en este fichero. Luego saca la primera palabra de cada una, ordénalas y guárdalas en un fichero `covid-seq-names.txt`.


### Respuesta ejercicio 3
Si recuerdas, los nombres de las secuencias en un `fasta` se marcan con un `>`. Podemos encontrar estas líneas con el comando `grep` y hacer que busque por el literal `>`:

```
abenito@cpg3:~/sesion-iii/fasta$ grep ">" covid-samples.fasta
>MW186669.1 |Severe acute respiratory syndrome coronavirus 2 isolate SARS-CoV-2/human/EGY/Cairo-sample 19 MOH/2020, complete genome
>MW186829.1 |Severe acute respiratory syndrome coronavirus 2 isolate SARS-CoV-2/human/EGY/Cairo-sample 2 MOH/2020 ORF1ab polyprotein (ORF1ab), ORF1a polyprotein (ORF1ab), surface glycoprotein (S), ORF3a protein (ORF3a), envelope protein (E), membrane glycoprotein (M), ORF6 protein (ORF6), ORF7a protein (ORF7a), ORF7b (ORF7b), ORF8 protein (ORF8), nucleocapsid phosphoprotein (N), and ORF10 protein (ORF10) genes, complete cds
>MW186830.1 |Severe acute respiratory syndrome coronavirus 2 isolate SARS-CoV-2/human/EGY/Cairo-sample 8 MOH/2020 ORF1ab polyprotein (ORF1ab), ORF1a polyprotein (ORF1ab), surface glycoprotein (S), ORF3a protein (ORF3a), envelope protein (E), membrane glycoprotein (M), ORF6 protein (ORF6), ORF7a protein (ORF7a), ORF7b (ORF7b), ORF8 protein (ORF8), nucleocapsid phosphoprotein (N), and ORF10 protein (ORF10) genes, complete cds
>MW181431.1 |Severe acute respiratory syndrome coronavirus 2 isolate SARS-CoV-2/human/USA/UT-00020/2020 ORF1ab polyprotein (ORF1ab), ORF1a polyprotein (ORF1ab), surface glycoprotein (S), ORF3a protein (ORF3a), envelope protein (E), membrane glycoprotein (M), ORF6 protein (ORF6), ORF7a protein (ORF7a), ORF7b (ORF7b), ORF8 protein (ORF8), nucleocapsid phosphoprotein (N), and ORF10 protein (ORF10) genes, complete cds
```

Extraemos la primera palabra de cada línea con cut. El truco está en usar el espacio en blanco como separador con `-d " "`. 

```
abenito@cpg3:~/sesion-iii/fasta$ grep ">" covid-samples.fasta | cut -f1 -d " " | head -n5
>MW186669.1
>MW186829.1
>MW186830.1
>MW181431.1
```

Finalmente, para ordenar los resultados, lo hacemos con el ya conocido `sort` y terminamos volcando la salida a un nuevo fichero:

```
grep ">" covid-samples.fasta | cut -f1 -d " " | sort > covid-seq-names.txt

abenito@cpg3:~/sesion-iii/fasta$ cat covid-seq-names.txt
>MW181431.1
>MW186669.1
>MW186829.1
>MW186830.1
```


## Ejercicio 4

Encuentra, usando una sola línea, el número de usuarias diferentes que tienen al menos una carpeta a su nombre en el '/home' de CPG3.

### Respuesta ejercicio 4
Para responder a este ejercicio, trazamos el siguiente plan: 

1. Listar las carpetas dentro de  `/home` con `ls -la`, lo cual nos dará detalles acerca de quién es la propietaria de cada una. 
2. Aislar la tercera columna (la que contiene lo nombres de las propietarias) con `cut`
3. Ordenarla y eliminar ocurrencias repetidas (con `sort | uniq`)
4. Contar con `wc`

El plan parece claro, pero si operamos como antes y tratamos de extraer la tercera columna usando el espacio en blanco como separador surgen problemas...

```
abenito@cpg3:~/sesion-iii/fasta$ ls -l /home/ | cut -d " " -f3

abenito
adrianambroa
agarmar
alba
9
1
amptoboso
anaromero
arqcarmel
carlosp
elenanavarro
3
giselcp
5
2
gualtierolugato
3
2
jorgeruizramirez
josanc
1
1
laudupri
2
2
lihuengd
2
2
msandreu
rafalopez
rodri
sagoji
7
theron
verogmartos
```

Como en la segunda columna (número de hard links) varía en longitud, el separar de esta manera no funciona!

Como podríamos solucionarlo? Como siempre, consultamos el manual y vemos que `cut` admite la opción de seleccionar porciones de caracteres con la opción `-c`. Haciendo un poco de trampa, podemos "medir" hasta dónde llega el nombre más largo y cortar por ahí. 

```
abenito@cpg3:~/sesion-iii/fasta$ ls -al /home | tail -n+2 | cut -c15-33
root
root
abenito
adrianambroa
agarmar
alba
alejandro
root
amptoboso
anaromero
arqcarmel
carlosp
elenanavarro
eval_user
giselcp
grader-python-bio
root
gualtierolugato
jibri
jmarcosberna
jorgeruizramirez
josanc
root
root
laudupri
lauraalvarezalvarez
lcorsan
lihuengd
root
luisasousa
msandreu
rafalopez
rodri
sagoji
seqview_user
theron
verogmartos
```

Ahora que ya tenemos lo que queríamos, podemos seguir el procedimiento ya conocido:

```
abenito@cpg3:~/sesion-iii/fasta$ ls -al /home | tail -n+2 | cut -c15-33 | sort | uniq | wc -l
31
```

Como ves, este enfoque no es muy escalable. Si tan solo `cut` fuera un poquito más inteligente como para hacerle distinguir qué es un nombre y qué no...

Por suerte, para suplir esta carencia tenemos las expresiones regulares y los comandos `awk` y `sed`, que se presentan en las próximas sesiones del curso.


