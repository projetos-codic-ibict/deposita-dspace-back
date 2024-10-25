#!/usr/bin/bash

# Copia os arquivos de script
ls -1 *.sql | while read arquivo; do
  docker cp "$arquivo" dspacedb:/tmp
done

docker exec dspacedb psql -U dspace -d dspace -f "/tmp/funcoes.sql"
docker exec dspacedb psql -U dspace -d dspace -f "/tmp/deleta-itens-sem-dc-type.sql"
docker exec dspacedb psql -U dspace -d dspace -f "/tmp/cria-metadado-regiao.sql"
docker exec dspacedb psql -U dspace -d dspace -f "/tmp/preprocessa-tipos.sql"
docker exec dspacedb psql -U dspace -d dspace -f "/tmp/deleta-dc-types-repetidos.sql"
docker exec dspacedb psql -U dspace -d dspace -f "/tmp/cria-colecoes-de-tipos.sql"
docker exec dspacedb psql -U dspace -d dspace -f "/tmp/atualiza-colecoes.sql"
