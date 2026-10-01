#!/usr/bin/env bash
# Install Docker on Ubuntu / Debian / WSL2 and set up the environment for the SQL exercises.
# Usage: ./install.sh
set -euo pipefail

if command -v docker >/dev/null 2>&1; then
  echo ">> Docker già installato: $(docker --version)"
else
  [ -r /etc/os-release ] || { echo "Sistema non riconosciuto (serve Ubuntu/Debian)." >&2; exit 1; }
  echo ">> Installo Docker (richiede sudo)..."
  curl -fsSL https://get.docker.com | sudo sh
fi

# Allow using docker without sudo
if ! id -nG "$USER" | grep -qw docker; then
  sudo usermod -aG docker "$USER"
  echo ">> Aggiunto $USER al gruppo docker (effettivo al prossimo login: 'newgrp docker' oppure riapri il terminale)."
fi

# Start the daemon: systemd if available, otherwise service (WSL without systemd)
if ! sudo docker info >/dev/null 2>&1; then
  echo ">> Avvio il demone Docker..."
  if [ -d /run/systemd/system ]; then sudo systemctl enable --now docker
  else sudo service docker start; fi
fi

# watch is needed for real-time query testing
command -v watch >/dev/null 2>&1 || sudo apt-get install -y procps

cd "$(dirname "$0")"
chmod +x scuola/run.sh turismo/run.sh
echo ">> Scarico l'immagine PostgreSQL..."
sudo docker pull postgres:16-alpine >/dev/null
echo
echo "Fatto. Prova:  cd scuola && ./run.sh"
