#!/usr/bin/env bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

ctrl_c(){
  wait
  echo -e "\n\n${redColour}[!WARN]${endColour} Ctr_c detectado saliendo...\n\n\n"
  exit 1
}

trap ctrl_c SIGINT

if [ $(whoami) == "root" ]; then
  echo -n
else
  echo -e "\n${redColour}[WARN]${endColour} El script requiere privilegios de root\n\n"
  exit 2
fi
echo -e "\n${yellowColour}[INFO]${endColour} Verificando dependecias..."
sleep 0.3
if which nmap &>/dev/null ; then
  echo
else
  sudo apt install nmap -y &>/dev/null && echo -e "\n${greenColour}[INFO]${endColour} Dependencias instaladas con exito." || {
    echo -e "${redColour}[!WARN]${endColour} No se pudo instalar las dependencias, instale las sigientes dependencias manualmente:\n\tnmap\n\n"; exit 2
  }
  echo
fi

machineip=$(hostname -I | awk '{print $1}')

hosts=()

port_scan(){
  echo -e "\n${greenColour}[+]${endColour} Iniciando escaneo de puertos..."
  echo -e "\n${blueColour}--------------------------------------------------------------------------${endColour}\n" 
  sleep 0.5
  for host in ${hosts[@]}; do
    echo -e "\n${greenColour}[+]${endColour} Escaneando puetos en ${turquoiseColour}${host}${endColour}\n"
    sudo nmap --min-rate 5000 -Pn -n -sS -p- ${host} | sed '$d' | sed '$d' | sed '1,5d' 2>/dev/null
    echo -e "\n${blueColour}--------------------------------------------------------------------------${endColour}\n" 
  done
  echo "Nada que hacer."
  echo -e "Hecho en $SECONDS segundos\n\n"
}

_scan(){
  echo -e "\n${greenColour}[+]${endColour} Iniciando escaneo...\n"
  sleep 0.2
  for host in {1..254}; do
    timeout 1 ping -c 1 ${red}.${host} &>/dev/null && {
      echo -e "\t${greenColour}[+]${endColour} Host ${red}.${host} ${greenColour}activo${endColour}"; echo "${red}.${host}" >> .hosts
    } &
    
  done; wait
  read -ra hosts <<< $(/usr/bin/cat .hosts | grep -v "$machineip" | xargs)
  echo -e "\n${yellowColour}[INFO]${endColour}${greenColour} Ok${endColour}"
  rm .hosts
  port_scan
}

manual_red(){
  echo -e "\n${yellowColour}[INFO]${endColour} Ejemplo 192.168.0"
  echo -en "${greenColour}[+]${endColour} Introduce la red a auditar: ${greenColour}" && read red
  echo -en "\n${endColour}${greenColour}[+] Ok${endColour} red: ${red} seteada\n"
}

echo -e "${yellowColour}[INFO]${endColour} Detectando red..."
sleep 0.8

red=$(hostname -I | awk '{print $1}' | sed 's/\.[^.]*$//' 2>/dev/null)

if [ "$red" ]; then
  echo -e "\n${greenColour}[+]${endColour} Red: ${red} detectada!\n"
  _scan
else
  echo -e "${redColour}[!WARN]${endColour} No se pudo detectar la red automaticamente\n"
  manual_red
fi

