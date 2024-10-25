WITH novas_colecoes AS (
    SELECT *
    FROM collection
    WHERE collection.uuid NOT IN (SELECT owning_collection FROM item)
), itens_a_terem_colecoes_atualizadas AS (
    SELECT *
    FROM item
    -- Atualiza somente onde os UUIDs de owning_collection que não estão presentes nas novas coleções
    WHERE owning_collection IS NULL OR owning_collection NOT IN (SELECT uuid FROM novas_colecoes)
), itens_mais_tipos AS (
    SELECT item.*, mv.text_value tipo
    FROM itens_a_terem_colecoes_atualizadas item
    JOIN metadatavalue mv
    ON
        mv.metadata_field_id = get_metadata_field_id('type', NULL) AND
        mv.dspace_object_id = item.uuid
), colecoes_mais_titulos AS (
    SELECT colecao.*, mv.text_value titulo
    FROM collection colecao
    JOIN metadatavalue mv
    ON
        mv.metadata_field_id = get_metadata_field_id('title', NULL) AND
        mv.dspace_object_id = colecao.uuid
), itens_mais_novos_uuids AS (
    SELECT item.*, colecao.uuid AS uuid_da_nova_colecao
    FROM itens_mais_tipos item
    JOIN colecoes_mais_titulos colecao
    ON
        item.tipo = colecao.titulo
), atualiza_em_item AS (
    UPDATE item
    SET owning_collection = (
        SELECT uuid_da_nova_colecao
        FROM itens_mais_novos_uuids item2
        WHERE item.uuid = item2.uuid
    )
), atualiza_em_cwf_workflowitem AS (
    UPDATE cwf_workflowitem
    SET collection_id = (
        SELECT uuid_da_nova_colecao
        FROM itens_mais_novos_uuids item2
        WHERE cwf_workflowitem.item_id = item2.uuid
    )
)

UPDATE workspaceitem
SET collection_id = (
    SELECT uuid_da_nova_colecao
    FROM itens_mais_novos_uuids item2
    WHERE workspaceitem.item_id = item2.uuid
)

;
