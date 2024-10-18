-- Isto cria uma coleção com:
--   - dc.description.title = 'aaa'
-- Falta:
--   - (Gabriel) dc.description.abstract = ''
--   - dc.identifier.uri = 'http://192.168.1.46:5000/handle/deposita/X' (em vez do X no final deve ter o metadata_value_id)
--   - (Gabriel) Descobrir como pegar uma tabela com UMA coluna que vai ter cada possibilidade de dc.type
--   - O dc.description.title deve ser pego a partir do dc.type do item, para cada possibilidade de dc.type
-- {{{
WITH inserted_object AS (
    INSERT INTO dspaceobject (uuid)
    VALUES (GEN_RANDOM_UUID())
    RETURNING uuid
), new_collection AS (
  INSERT INTO collection (
    collection_id,
    uuid
  )
  VALUES (
    (SELECT COALESCE(MAX(collection_id), 0) + 1 FROM collection),
    (SELECT uuid FROM inserted_object)
  )
  RETURNING uuid
)
INSERT INTO metadatavalue (metadata_field_id, text_value, text_lang, place, authority, dspace_object_id)
VALUES (
  (
    SELECT metadata_field_id
    FROM metadatafieldregistry
    WHERE
    metadata_schema_id = (SELECT metadata_schema_id FROM metadataschemaregistry where short_id = 'dc') AND
    element = 'title' AND
    qualifier IS NULL
  ),
  'aaa',                            -- text_value
  'por',                            -- text_lang
  0,                                -- place
  '',                               -- authority
  (SELECT uuid FROM new_collection) -- dspace_object_id
)
-- }}}
;
