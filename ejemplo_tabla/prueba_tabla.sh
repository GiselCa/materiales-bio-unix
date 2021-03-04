#!/bin/bash
set -e
set -u
set -o pipefail

TABLA_SECUENCIA=`cat tabla.md`

#Frecuencias absolutas
contador=1
for dato in freq_A1 freq_A2 freq_A3 freq_A4
do
    TABLA_SECUENCIA=`echo "$TABLA_SECUENCIA" | sed "s/TABLA_${contador}1/${dato}/"`
    contador=$(($contador+1))
done

#Frecuencias relativas
contador=1
for dato in freq_R1 freq_R2 freq_R3 freq_R4
do
    TABLA_SECUENCIA=`echo "$TABLA_SECUENCIA" | sed "s/TABLA_${contador}2/${dato}/"`
    contador=$(($contador+1))
done

echo "$TABLA_SECUENCIA" | tee tabla_modificada.md

exit 0

