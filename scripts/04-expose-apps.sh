#!/bin/bash
# Repassa as portas da VM para os NodePorts do Minikube (Etapa 5).
# Executar dentro da VM, depois do 03-deploy-apps.sh.
#
# Por que: com o driver docker, o Minikube roda num container com IP interno
# (ex.: 192.168.49.2), que o Load Balancer do OpenStack não alcança.
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

# Teste local
curl -s "localhost:8081/v1/cpu_bound/primos?enesimo=20"; echo
curl -s "localhost:8082/v1/io_bound/arquivo"; echo
curl -s "localhost:8083/v1/main/estatisticas?enesimo=1000"; echo
