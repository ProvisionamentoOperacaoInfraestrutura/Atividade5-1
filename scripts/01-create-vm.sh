#!/bin/bash
# Criando a VM
# O security group sg-grupo-5 foi reaproveitado das atividades anteriores, pois
# já libera SSH (22), ICMP e as portas necessárias para as apps (5001-5003 e 8081-8083)
set -e

openstack server create \
  --image ubuntu-24.04 \
  --flavor general.large \
  --network provider \
  --key-name chave-g5 \
  --security-group sg-grupo-5 \
  atv5-grupo5

# Acesso (precisa estar na rede do LSD ou na VPN):
# ssh -i ~/.ssh/chave-g5.pem ubuntu@10.5.9.127
