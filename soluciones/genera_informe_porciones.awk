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
