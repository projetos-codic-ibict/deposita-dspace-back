#!/usr/bin/bash

# Copia os arquivos de script
ls -1 *.sql | while read arquivo; do
  docker cp "$arquivo" dspacedb:/tmp
done

SCRIPTS=(
  "/tmp/funcoes.sql"
  "/tmp/deleta-itens-sem-dc-type.sql"
  "/tmp/cria-metadado-regiao.sql"
  "/tmp/preprocessa-tipos.sql"
  "/tmp/deleta-dc-types-repetidos.sql"
  "/tmp/cria-colecoes-de-tipos.sql"
  "/tmp/atualiza-colecoes.sql"
  "/tmp/apaga-colecoes-antigas.sql"
)

for script in ${SCRIPTS[@]}; do
  echo "Rodando script $script"
  docker exec dspacedb psql -U dspace -d dspace -f "$script"
done
