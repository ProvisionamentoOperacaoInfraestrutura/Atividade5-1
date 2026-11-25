#!/bin/bash
# Faz o deploy das três aplicações no Minikube (Etapa 4).
# Executar dentro da VM, na raiz do repositório.
set -e

kubectl apply -f k8s/

# Espera os pods ficarem prontos
kubectl rollout status deployment/cpu-bound
kubectl rollout status deployment/io-bound
kubectl rollout status deployment/memory-bound

kubectl get pods -o wide
