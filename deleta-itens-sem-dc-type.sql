WITH itens_que_devem_ser_excluidos AS (
    SELECT *
    FROM item
    WHERE
        uuid not in (
            SELECT dspace_object_id
            FROM metadatavalue
            WHERE metadata_field_id = get_metadata_field_id('type', NULL)
        )
), _deleta_itens_de_workspaceitem AS (
  DELETE
  FROM workspaceitem wi
  WHERE wi.item_id IN (SELECT uuid from itens_que_devem_ser_excluidos)
), _deleta_itens_de_item AS (
  DELETE
  FROM item
  WHERE item.uuid IN (SELECT uuid from itens_que_devem_ser_excluidos)
), _deleta_itens_de_dspace_object AS (
  DELETE
  FROM dspaceobject
  WHERE uuid IN (SELECT uuid from itens_que_devem_ser_excluidos)
), _deleta_itens_de_collection2item AS (
  DELETE
  FROM collection2item
  WHERE item_id IN (SELECT uuid from itens_que_devem_ser_excluidos)
)

DELETE
FROM item2bundle
WHERE item_id IN (SELECT uuid from itens_que_devem_ser_excluidos)

;
