# LocalScan
Escáner de red local en bash. Detecta hosts activos por trazas ICMP y les hace un escaneo al rango total de puertos..

## Cómo funciona

1. **Detección de red** — Intenta detectar la red local automáticamente a partir de la IP de la máquina. Si no puede, te pide la red manualmente.
2. **Discovery de hosts** — Lanza pings ICMP en paralelo (254 hosts a la vez) para ver quiénes están vivos.
3. **Escaneo de puertos** — Para cada host activo, ejecuta `nmap -sS` a toda la gama de puertos (1-65535) con `--min-rate 5000` para que no se eternice.

## Requisitos

- Linux
- `nmap` instalado
- Privilegios de root (nmap con SYN scan los necesita)

## Uso

```bash
git clone https://github.com/RootFor0x1337/LocalScan.git
cd LocalScan
chmod +x localscan.sh
sudo ./localscan.sh
