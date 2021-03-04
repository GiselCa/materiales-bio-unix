#!/bin/bash
set -e
set -u
set -o pipefail

#Ejemplo de script Bash para crear tablas de frecuencias
#de nucléotidos para una secuencia a partir de una plantilla en Markdown.
#La tabla se guarda en una variable TABLA_SECUENCIA usando la orden cat
#y luego se reemplazan los placeholders con sed en un bucle.

#Fíjate cómo rodeo con comillas dobles la expansión de la variable con comillas dobles
#la variable para mantener los saltos de línea (si no, habría que escaparlos con \).

#Todo esto podría estar dentro de un bucle más grande que iterase por cada una de las secuencias
#de un fasta (podríamos por ejemplo extraer cada una a un fichero temporal que sería procesado
#individualmente).

#Luego podríamos añadir cada una de las tablas al final del informe que estuviésemos creando
#usando el operador de redirección >>.

TABLA_SECUENCIA=`cat tabla.md`

#Frecuencias absolutas
contador=1
for dato in freq_A1 freq_A2 freq_A3 freq_A4 #valores de fas ficticios (a obtener de un pipeline)
do
    TABLA_SECUENCIA=`echo "$TABLA_SECUENCIA" | sed "s/TABLA_${contador}1/${dato}/"`
    contador=$(($contador+1))
done

#Frecuencias relativas
contador=1
for dato in freq_R1 freq_R2 freq_R3 freq_R4 #valores de frs ficticios (a obtener de un pipeline)
do
    TABLA_SECUENCIA=`echo "$TABLA_SECUENCIA" | sed "s/TABLA_${contador}2/${dato}/"`
    contador=$(($contador+1))
done

echo "$TABLA_SECUENCIA" | tee tabla_modificada.md

exit 0

