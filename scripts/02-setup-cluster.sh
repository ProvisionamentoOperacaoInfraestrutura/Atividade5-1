#!/bin/bash
# Instala Docker, kubectl e Minikube e inicia o cluster (Etapa 3).
# Executar dentro da VM atv5-grupo5 (Ubuntu 24.04), como usuário ubuntu.

# Dependências: socat será usado na Etapa 5 para encaminhar portas da VM ao Minikube.
sudo apt update && sudo apt -y upgrade
sudo apt -y install curl conntrack ca-certificates socat

# Docker
if ! command -v docker >/dev/null; then
  curl -fsSL https://get.docker.com | sudo sh
fi
sudo usermod -aG docker "$USER"

# kubectl
if ! command -v kubectl >/dev/null; then
  curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -m 0755 kubectl /usr/local/bin/kubectl
  rm -f kubectl
fi

# Minikube
if ! command -v minikube >/dev/null; then
  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  sudo install minikube-linux-amd64 /usr/local/bin/minikube
  rm -f minikube-linux-amd64
fi

# Cluster
# 4 vCPUs e 6 GB: tetos do container do Minikube (a VM tem 4 vCPUs e 8 GB).
# 'sg docker' aplica o grupo docker sem precisar sair e entrar no SSH.
sg docker -c "minikube start --driver=docker --cpus=4 --memory=6144"

# Verificando se deu tudo certo
kubectl get nodes
kubectl get pods -A
