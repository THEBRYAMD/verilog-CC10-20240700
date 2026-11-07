CC10 - Medidor de duracion de pulsaciones



Asignatura: Sistemas Digitales

Matricula: 20240700

Correo: 20240700@itla.edu.do



Objetivo:

Implementar un circuito digital en Verilog que mida

la duracion de una pulsacion y determine si es

corta o larga



Archivos del repositorio:
top\_module.v   Implementación sintetizable del medidor.

tb\_student.v   Banco de pruebas con estímulos y comprobaciones automáticas.

README.md

.gitignore





Plan de desarrollo:

**1. Crear interfaz y estructura inicial**



El módulo utiliza cuatro registros de estado:

contador (8 bits): acumula muestras altas, con saturación en 255.

duracion (8 bits): conserva la última duración publicada.

valid (1 bit): señala durante un solo ciclo una publicación nueva.

long\_press (1 bit): conserva la clasificación de la última pulsación.

Toda la lógica secuencial está en un bloque always y las actualizaciones de registros utilizan asignaciones no bloqueantes. No se emplean relojes derivados ni retardos de simulación dentro del módulo sintetizable.





2\. Implementar contador y clasificación



El contador solo tiene 8 bits, por lo que su mayor valor es 255. Si se incrementara sin protección, pasaría de 255 a 0 por desbordamiento. Para evitarlo, la implementación solo suma cuando contador < 8'd255.

Por tanto, una pulsación de 260 ciclos se publica como duración 255, no como 4 ni como 0. Con K=3 o K=5, al liberar el botón la salida esperada es 16'h03FF. En el flanco siguiente, si no ocurre una nueva pulsación, la salida pasa a 16'h02FF, conservando la duración y la clasificación.





3\. Crear pruebas automaticas y depurar

tb\_student instancia dos veces el módulo (K=3 y K=5), genera un reloj de período 10 ns, aplica señales antes del flanco positivo y compara las salidas 1 ns después de cada flanco. Las comparaciones usan !== para detectar también valores desconocidos (X) y de alta impedancia (Z).



Resultados de las ejecuciones locales realizadas durante el desarrollo:



Pulsación de 2 ciclos; publicación corta------**Superada**

Pulsación de 3 ciclos; larga para K=3 y corta para K=5----**Superada**

valid retorna a 0 y se conserva el resultado----**Superada en las pruebas iniciales**

Pulsación de 1 ciclo----**Superada**

Pulsación de 255 ciclos----**Superada**

Pulsación de 260 ciclos; saturación en 255------**Superada**

Pruebas ampliadas de pausa, reset y fronteras K−1/K-------**Superada**

Secuencia pseudoaleatoria reproducible de 900 ciclos------**Superada**





Herramientas:

Gowin EDA

Icarus Verilog

Git



link del git:

https://github.com/THEBRYAMD/verilog-CC10-20240700

