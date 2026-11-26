#!/bin/bash
# Configura o Load Balancer do OpenStack (Etapa 7).
# Executar na máquina com o openstack CLI (com o openrc carregado), não na VM.
#
# Para cada aplicação: listener (porta pública do LB) -> pool -> member (VM:porta do socat)
#   LB:5101 -> VM:8081 (cpu-bound)
#   LB:5102 -> VM:8082 (io-bound)
#   LB:5103 -> VM:8083 (memory-bound)
#
# Uso: ./scripts/06-load-balancer.sh <ID_OU_NOME_DO_LB>
#   (ver com: openstack loadbalancer list)
set -e

if [ -z "$1" ]; then
  echo "Uso: $0 <ID_OU_NOME_DO_LB>"
  exit 1
fi

LB_NAME="$1"
VM_NAME="atv5-grupo5"

VM_IP=$(openstack server show "$VM_NAME" -f value -c addresses | grep -oE '[0-9]+(\.[0-9]+){3}' | head -1)
echo "IP da VM: $VM_IP"

# O Octavia não aceita alterações enquanto o LB está em PENDING_UPDATE
esperar_lb() {
  until [ "$(openstack loadbalancer show "$LB_NAME" -f value -c provisioning_status)" = "ACTIVE" ]; do
    sleep 3
  done
}

criar() {
  local app=$1 porta_lb=$2 porta_vm=$3

  esperar_lb
  openstack loadbalancer listener create --name "listener-$app-grupo-5" \
    --protocol TCP --protocol-port "$porta_lb" "$LB_NAME"

  esperar_lb
  openstack loadbalancer pool create --name "pool-$app-grupo-5" \
    --lb-algorithm ROUND_ROBIN --listener "listener-$app-grupo-5" --protocol TCP

  esperar_lb
  openstack loadbalancer member create --name "member-$app-grupo-5" \
    --address "$VM_IP" --protocol-port "$porta_vm" "pool-$app-grupo-5"
}

criar cpu-bound    5101 8081
criar io-bound     5102 8082
criar memory-bound 5103 8083

esperar_lb
VIP=$(openstack loadbalancer show "$LB_NAME" -f value -c vip_address)
echo
echo "CPU:    http://$VIP:5101/v1/cpu_bound/primos?enesimo=10000"
echo "IO:     http://$VIP:5102/v1/io_bound/arquivo"
echo "Memory: http://$VIP:5103/v1/main/estatisticas?enesimo=10000"
