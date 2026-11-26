#!/bin/bash
# Testa as três aplicações de dentro da VM, pelas portas do socat (Etapa 6).
# Executar dentro da VM, depois do 04-expose-apps.sh.

echo "== CPU bound (8081)"
curl -s "localhost:8081/v1/cpu_bound/primos?enesimo=20"; echo

echo "== IO bound (8082)"
curl -s "localhost:8082/v1/io_bound/arquivo"; echo

echo "== Memory bound (8083)"
curl -s "localhost:8083/v1/main/estatisticas?enesimo=1000"; echo
