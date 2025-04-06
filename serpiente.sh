#!/bin/bash

# Función para generar una posición aleatoria para la manzana
apple() {
   # Calcula una posición X aleatoria dentro del área definida
   APPLEX=$(( RANDOM % (AREAMAXX - AREAMINX + 1) + AREAMINX ))
   # Calcula una posición Y aleatoria dentro del área definida
   APPLEY=$(( RANDOM % (AREAMAXY - AREAMINY + 1) + AREAMINY ))
}

# Función para dibujar la manzana en la pantalla
drawapple() {
   # Obtiene el índice del último elemento en el array de posiciones de la serpiente
   LASTEL=$(( ${#LASTPOSX[@]} - 1 ))
   x=0
   apple
   # Verifica que la posición de la manzana no coincida con la posición de la serpiente
   while [ "$x" -le "$LASTEL" ]; do
      if [ "$APPLEX" = "${LASTPOSX[$x]}" ] && [ "$APPLEY" = "${LASTPOSY[$x]}" ]; then
         x=0
         apple
      else
         x=$(( x + 1 ))
      fi
   done
   # Cambia el color del texto a rojo
   tput setaf 4
   # Coloca el cursor en la posición de la manzana
   tput cup $APPLEY $APPLEX
   # Imprime el carácter de la manzana
   printf "%b" "$APPLECHAR"
   # Restablece el color del texto a blanco
   tput setaf 7
}

# Función para hacer crecer la serpiente
growsnake() {
   # Añade tres nuevas posiciones al inicio de los arrays de posiciones de la serpiente
   LASTPOSX=( "${LASTPOSX[0]}" "${LASTPOSX[0]}" "${LASTPOSX[0]}" "${LASTPOSX[@]}" )
   LASTPOSY=( "${LASTPOSY[0]}" "${LASTPOSY[0]}" "${LASTPOSY[0]}" "${LASTPOSY[@]}" )
   RET=1
   # Genera una nueva posición para la manzana hasta que sea válida
   while [ "$RET" -eq 1 ]; do
      apple
      RET=$?
   done
   drawapple
}

# Función para mover la serpiente
move() {
   # Cambia la posición de la serpiente según la dirección
   case "$DIRECTION" in
      u) POSY=$(( POSY - 1 ));;
      d) POSY=$(( POSY + 1 ));;
      l) POSX=$(( POSX - 1 ));;
      r) POSX=$(( POSX + 1 ));;
   esac

   # Programa una alarma para mover la serpiente después de un retraso
   ( sleep $DELAY && kill -ALRM $$ ) &
   # Verifica si la serpiente ha chocado con un muro
   if [ "$POSX" -le "$FIRSTCOL" ] || [ "$POSX" -ge "$LASTCOL" ]; then
      tput cup $(( LASTROW + 1 )) 0
      stty echo
      echo "JUEGO PERDIDO! CHOCASTE CON UN MURO!"
      gameover
   elif [ "$POSY" -le "$FIRSTROW" ] || [ "$POSY" -ge "$LASTROW" ]; then
      tput cup $(( LASTROW + 1 )) 0
      stty echo
      echo "JUEGO PERDIDO! CHOCASTE CON UN MURO!"
      gameover
   fi

   LASTEL=$(( ${#LASTPOSX[@]} - 1 ))

   x=1
   # Verifica si la serpiente ha chocado consigo misma
   while [ "$x" -le "$LASTEL" ]; do
      if [ "$POSX" = "${LASTPOSX[$x]}" ] && [ "$POSY" = "${LASTPOSY[$x]}" ]; then
         tput cup $(( LASTROW + 1 )) 0
         echo "JUEGO PERDIDO! TE MORDISTE!"
         gameover
      fi
      x=$(( x + 1 ))
   done

   # Borra la posición más antigua de la serpiente en la pantalla
   tput cup ${LASTPOSY[0]} ${LASTPOSX[0]}
   printf " "

   # Actualiza los arrays de posiciones de la serpiente
   LASTPOSX=( "${LASTPOSX[@]:1}" "$POSX" )
   LASTPOSY=( "${LASTPOSY[@]:1}" "$POSY" )

   tput cup 1 10
   tput cup 2 10
   echo "SIZE=${#LASTPOSX[@]}"

   LASTPOSX[$LASTEL]=$POSX
   LASTPOSY[$LASTEL]=$POSY

   # Dibuja la nueva posición de la serpiente
   tput setaf 2
   tput cup $POSY $POSX
   printf "%b" "$SNAKECHAR"
   tput setaf 9

   # Verifica si la serpiente ha comido una manzana
   if [ "$POSX" -eq "$APPLEX" ] && [ "$POSY" -eq "$APPLEY" ]; then
      growsnake
      updatescore 10
   fi
}

# Función para actualizar el puntaje
updates   SCORE=$(( SCORE + $1 ))
   tput cup 2 30
   printf "SCORE: %d" "$SCORE"
}

# Función para seleccionar una dirección aleatoria
randomchar() {
    [ $# -eq 0 ] && return 1
    n=$(( (RANDOM % $#) + 1 ))
    eval DIRECTION=\${$n}
}

# Función para finalizar el juego
gameover() {
   tput cvvis
   stty echo
   sleep $DELAY
   trap exit ALRM
   tput cup $ROWS 0
   exit
}

# Función para dibujar el borde del área de juego
drawborder() {
   tput setaf 6
   tput cup $FIRSTROW $FIRSTCOL
   x=$FIRSTCOL
   while [ "$x" -le "$LASTCOL" ]; do
      printf "%b" "$WALLCHAR"
      x=$(( x + 1 ))
   done

   x=$FIRSTROW
   while [ "$x" -le "$LASTROW" ]; do
      tput cup $x $FIRSTCOL
      printf "%b" "$WALLCHAR"
      tput cup $x $LASTCOL
      printf "%b" "$WALLCHAR"
      x=$(( x + 1 ))
   done

   tput cup $LASTROW $FIRSTCOL
   x=$FIRSTCOL
   while [ "$x" -le "$LASTCOL" ]; do
      printf "%b" "$WALLCHAR"
      x=$(( x + 1 ))
   done
   tput setaf 9
}

# Caracteres para la serpiente, el muro y la manzana
SNAKECHAR="@"
WALLCHAR="X"
APPLECHAR="o"

# Tamaño inicial de la serpiente y otros parámetros
SNAKESIZE=3
DELAY=0.2
FIRSTROW=3
FIRSTCOL=1
LASTCOL=79
LASTROW=20
AREAMAXX=$(( LASTCOL - 1 ))
AREAMINX=$(( FIRSTCOL + 1 ))
AREAMAXY=$(( LASTROW - 1 ))
AREAMINY=$(( FIRSTROW + 1 ))
ROWS=$(tput lines)
ORIGINX=$(( LASTCOL / 2 ))
ORIGINY=$(( LASTROW / 2 ))
POSX=$ORIGINX
POSY=$ORIGINY

# Inicialización de las posiciones de la serpiente
ZEROES=$(printf "%0${SNAKESIZE}d" | sed 's/0/0 /g')
LASTPOSX=( $ZEROES )
LASTPOSY=( $ZEROES )

SCORE=0

# Configuración inicial del juego
clear
echo "
TECLAS:

 W - ARRIBA
 S - ABAJO
 A - IZQUIERDA
 D - DERECHA
 X - SALIR

PRESIONA RETURN PARA CONTINUAR
"

stty -echo
tput civis
read -r RTN
tput setb 0
tput bold
clear
drawborder
updatescore 0

drawapple
sleep 1
trap move ALRM

DIRECTIONS=( u d l r )
randomchar "${DIRECTIONS[@]}"

sleep 1
move
while :; do
   read -rsn1 key
   case "$key" in
      w) DIRECTION="u";;
      s) DIRECTION="d";;
      a) DIRECTION="l";;
      d) DIRECTION="r";;
      x)
         tput cup $COLS 0
         echo "Quitting..."
         tput cvvis
         stty echo
         tput reset
         printf "HASTA LA VISTA BABY!\n"
         trap exit ALRM
         sleep $DELAY
         exit 0
         ;;
   esac
done