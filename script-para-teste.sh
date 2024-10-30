#!/usr/bin/bash

./chama-scripts-da-migracao.sh

echo "Limpando index"
docker exec dspace /dspace/bin/dspace index-discovery -c

echo "Criando novo index"
docker exec dspace /dspace/bin/dspace index-discovery -f

echo "Criando um usuário normal"
docker exec dspace /dspace/bin/dspace user --add --email "usuarionormal@gmail.com" -g "a" -s "b" --password "a"

echo "Criando um usuário administrador"
docker exec dspace /dspace/bin/dspace create-administrator --email "usuarioadmin@gmail.com" --first "a" --last "b" --language "pt_BR" --password "a"

notify-send "Terminado"
