
## Ejecución concurrente de ordenamiento por mezcla (Keveen)

#### De que trata el programa
En este repositorio hay un archivo llamado *merge_sort.py* el cual es un complemento para el programa con MPI, este script Merge Sort consiste en un algoritmo divide y venceras . Divide la matriz de entrada en dos mitades, se llama a sí mismo para las dos mitades y luego fusiona las dos mitades ordenadas. La función merge() se utiliza para fusionar dos mitades. El merge(arr, l, m, r) es un proceso clave que asume que arr[l..m] y arr[m+1..r] están ordenados y fusiona los dos subarreglos ordenados en uno solo. 

En el script parallel_merge_sort.py se hizo una comunicación colectiva usando MPi y a grandes razgos el programa cuenta con un proceso trabajador donde lo primero que hace es crear un arreglo desordenado y los procesos trabajadores crean subarreglos, dado que el proceso maestro les envia los valores que contiene el subarreglo, para que cada proceso trabajador los ordene mediante merge sort.

#### Pasos previos a la ejecución

Para ejecutar el programa *parallel_merge_sort.py* de manera concurrente debemos de ocupar el cluster y usaremos la raspberry que se configuro como manager y posteriormente, debemos de tener una carpeta compartida donde alojaremos el programa( la carpeta nos sirve para que en dado caso que queramos ocupar las otras raspberry). Para poner el codigo en nuestra carpeta compartida usaremos el siguiente comando:
```
scp /home/alanbc/mpi_cluster/parallel_merge_sort.py pi2@172.30.2.X:~/mpi_drive
```
Donde "**/home/alanbc/mpi_cluster/**" es la ruta completa donde se encuentra nuestro programa localmente y aquí x representa nodo maestro. Esto lo debemos de hacer en la terminal de nuestro usuario sin loguearnos a una raspberry.

[![directorio-compartido.png](https://i.postimg.cc/rwmqnZH6/directorio-compartido.png)](https://postimg.cc/mtvxhjRV)

#### Ejecución del programa 

Una vez realizados los pasos previos a la ejecución, como se mencionaba En este repositorio hay un archivo llamado parallel_merge.sort.py, el cual aparte de los comandos de MPI, necesita parametros, los cuales son:

- argv[1]: El método seed() se utiliza para inicializar el generador de números aleatorios, donde el generador de números aleatorios necesita un número con el que empezar (un valor semilla), para poder generar un número aleatorio.

- argv[2]: Es el limite inferior del arreglo, es decir, el número más pequeño que se encontrara en el.

- argv[3]: Es el limite superior del arreglo, es decir, el número más grande que se encontrara en el.

- argv[4]: Aquí debemos de indicar el tamaño de nuestro arreglo principal(inicial).

- argv[5]: En este argumento debemos de indicar el nombre del archivo donde se guardará el resultado (previamente crear el archivo).

Donde todo lo anteriormente dicho se veria de la siguiente manera:
```
mpirun -n 2 python3 parallel_merge_sort.py 1 -1 12 10 marge.txt
```

### En caso de error en la configuración: 

Revisión de los archivos fstab y exports

En dado caso que el archivo que subimos en la carpeta compartida  no se encuentra en la raspberry de los trabajadres podemos revisar la sección de *mpi_conf.ssh* y en el apartado de Configuración del trabajador de aqui del Readme, donde nos dice que debemos de revisar el archivo fstab (es el directorio remoto que usarán los múltiples clientes para escribir sus respuestas)
  
Este archivo fstab en los nodos trabajadores deberia de tener lo siguiente:

[![fstab2.png](https://i.postimg.cc/CMmz72M0/fstab2.png)](https://postimg.cc/Hj8YsB7v)

Como nuestro archivo lo guardamos en la carpeta mpi-drive, nos deberia de fijar en la siguiente linea:
```
"172.30.2.x:/home/pi2/mpi-drive /home/pi2/mpi-drive nfs" , en donde x indica el número del nodo maestro.
```

Tambien en el mismo readme en esa sección de *mpi_conf.ssh*, pero ahora en el apartado de la configuración del manager, este mismo nos indica que en el archivo exports(ubicado en /etc) deberá de tener lo siguiente:

[![exports.png](https://i.postimg.cc/nzLYSDmc/exports.png)](https://postimg.cc/SXwMJjVw)

La linea que nos interesa tener es: "/home/pi2/mpi-drive *(rw,sync,no_root_squash,no_subtree_check)"


### Revisión del estado de NFS

Puede que el servicio nfs este inactivo en el nodo maestro y eso podemos revisar con el comando *sudo service nfs-common -status* y para los nodos trabajadores usamos *sudo service nfs-kernel-server -status*, en caso de que es servicio se encuentre inactivo o sea necesario reiniciar para aplicar cambios en nuestra raspberry podemos reiniciar el servicio con el comando: sudo systemctl restart nfs-kernel-server

En caso de tener esta situacion en varios nodos podemos utilizar el siguiente script para reiniciar los nodos de un cluster de manera mas rapida: 
```
!/usr/bin/env bash
$1 mode [manager, worker]
worker1_ip=172.30.2.1
worker2_ip=172.30.2.2
worker3_ip=172.30.2.3
worker4_ip=172.30.2.4
ssh -o StrictHostKeyChecking=no $worker1_ip 'sudo systemctl restart nfs-kernel-server'
ssh -o StrictHostKeyChecking=no $worker2_ip 'sudo systemctl restart nfs-kernel-server'
ssh -o StrictHostKeyChecking=no $worker3_ip 'sudo systemctl restart nfs-kernel-server'
ssh -o StrictHostKeyChecking=no $worker4_ip 'sudo systemctl restart nfs-kernel-server'
```
