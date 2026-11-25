#!/bin/bash
# Configura o Load Balancer do OpenStack (Etapa 6).
# Executar na máquina com o openstack CLI (com o openrc carregado), não na VM.
#
# Para cada aplicação: listener (porta pública do LB) -> pool -> member (VM:porta do socat)
#   LB:5001 -> VM:8081 (cpu-bound)
#   LB:5002 -> VM:8082 (io-bound)
#   LB:5003 -> VM:8083 (memory-bound)
set -e

LB_NAME="COLOQUE_O_NOME_DO_LB_AQUI"   # ver com: openstack loadbalancer list
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
  openstack loadbalancer listener create --name "listener-$app" \
    --protocol TCP --protocol-port "$porta_lb" "$LB_NAME"

  esperar_lb
  openstack loadbalancer pool create --name "pool-$app" \
    --lb-algorithm ROUND_ROBIN --listener "listener-$app" --protocol TCP

  esperar_lb
  openstack loadbalancer member create --name "member-$app" \
    --address "$VM_IP" --protocol-port "$porta_vm" "pool-$app"
}

criar cpu-bound    5001 8081
criar io-bound     5002 8082
criar memory-bound 5003 8083

esperar_lb
VIP=$(openstack loadbalancer show "$LB_NAME" -f value -c vip_address)
echo
echo "CPU:    http://$VIP:5001/v1/cpu_bound/primos?enesimo=10000"
echo "IO:     http://$VIP:5002/v1/io_bound/arquivo"
echo "Memory: http://$VIP:5003/v1/main/estatisticas?enesimo=10000"
