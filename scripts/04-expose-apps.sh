#!/bin/bash
# Executar dentro da VM, depois do 03-deploy-apps.sh.
#
# O socat escuta na VM e repassa para o Minikube:
#   VM:8081 -> Minikube:30081 (cpu-bound)
#   VM:8082 -> Minikube:30082 (io-bound)
#   VM:8083 -> Minikube:30083 (memory-bound)
set -e

MINIKUBE_IP=$(minikube ip)

# Encerra repasses antigos, se houver
pkill -f "socat TCP-LISTEN:808" || true

nohup socat TCP-LISTEN:8081,fork,reuseaddr TCP:$MINIKUBE_IP:30081 >/dev/null 2>&1 &
nohup socat TCP-LISTEN:8082,fork,reuseaddr TCP:$MINIKUBE_IP:30082 >/dev/null 2>&1 &
nohup socat TCP-LISTEN:8083,fork,reuseaddr TCP:$MINIKUBE_IP:30083 >/dev/null 2>&1 &

sleep 1
kubectl get services

