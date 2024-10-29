WITH itens_que_devem_ser_excluidos AS (
    SELECT *
    FROM item
    WHERE
        uuid not in (
            SELECT dspace_object_id
            FROM metadatavalue
            WHERE metadata_field_id = get_metadata_field_id('type', NULL)
        ) OR
        (
            SELECT text_value
            FROM metadatavalue
            WHERE
              metadata_field_id = get_metadata_field_id('type', NULL) AND
              dspace_object_id = item.uuid
        ) IN ('Relatório', 'Dados científicos', 'Objetos de aprendizagem', 'other', 'report')
), _deleta_itens_de_workspaceitem AS (
  DELETE
  FROM workspaceitem wi
  WHERE wi.item_id IN (SELECT uuid FROM itens_que_devem_ser_excluidos)
), _deleta_itens_de_item AS (
  DELETE
  FROM item
  WHERE item.uuid IN (SELECT uuid FROM itens_que_devem_ser_excluidos)
), _deleta_itens_de_cwf_pooltask AS (
  DELETE
  FROM cwf_pooltask
  WHERE workflowitem_id IN (
    SELECT workflowitem_id
    FROM cwf_workflowitem AS wi
    WHERE wi.item_id IN (SELECT uuid FROM itens_que_devem_ser_excluidos)
  )
), _deleta_itens_de_cwf_workflowitem AS (
  DELETE
  FROM cwf_workflowitem
  WHERE item_id IN (SELECT uuid FROM itens_que_devem_ser_excluidos)
), _deleta_itens_de_handle AS (
  DELETE
  FROM handle
  WHERE resource_id IN (SELECT uuid FROM itens_que_devem_ser_excluidos)
), _deleta_itens_de_dspace_object AS (
  DELETE
  FROM dspaceobject
  WHERE uuid IN (SELECT uuid FROM itens_que_devem_ser_excluidos)
), _deleta_itens_de_collection2item AS (
  DELETE
  FROM collection2item
  WHERE item_id IN (SELECT uuid FROM itens_que_devem_ser_excluidos)
)

DELETE
FROM item2bundle
WHERE item_id IN (SELECT uuid from itens_que_devem_ser_excluidos)

;
