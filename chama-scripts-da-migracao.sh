#!/usr/bin/bash

./copia-scripts-da-migracao.sh

SCRIPTS=(
  "/tmp/funcoes.sql"
  "/tmp/deleta-dc-types-repetidos.sql"
  "/tmp/deleta-itens-com-dc-type-invalido.sql"
  "/tmp/cria-metadados-necessarios.sql"
  "/tmp/adiciona-valores-de-metadado-regiao.sql"
  "/tmp/preprocessa-tipos.sql"
  # "/tmp/cria-colecao.sql"
  "/tmp/cria-colecoes-de-tipos.sql"
  "/tmp/atualiza-colecoes.sql"
  "/tmp/apaga-colecoes-antigas.sql"
  "/tmp/posprocessa-tipos.sql"
  "/tmp/apaga-funcoes.sql"
)

for script in ${SCRIPTS[@]}; do
  echo "Rodando script $script"
  docker exec dspacedb psql -U dspace -d dspace -f "$script"
done
