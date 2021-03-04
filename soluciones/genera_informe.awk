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
