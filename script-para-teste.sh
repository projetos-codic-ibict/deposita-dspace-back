#!/usr/bin/bash

./chama-scripts-da-migracao.sh

echo "Limpando index"
docker exec dspace /dspace/bin/dspace index-discovery -c

echo "Criando novo index"
docker exec dspace /dspace/bin/dspace index-discovery -f

notify-send "Terminado"
