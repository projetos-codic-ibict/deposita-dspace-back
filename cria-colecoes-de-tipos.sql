-- Isto cria uma coleção para cada dc.type com:
--   - dc.title = valor do dc.type
--   - dc.abstract.description = '' (descrição vazia)
--   - dc.identifier.uri = 'http://192.168.1.46:5000/handle/{handle}' ({handle} é deposita/2, deposita/3, etc...)

WITH tipos AS (
  SELECT DISTINCT ON (text_value) text_value, (GEN_RANDOM_UUID()) uuid
  FROM metadatavalue
  WHERE metadata_field_id = (
    SELECT metadata_field_id
    FROM metadatafieldregistry
    WHERE
      metadata_schema_id = (SELECT metadata_schema_id FROM metadataschemaregistry WHERE short_id = 'dc') AND
      element = 'type' AND
      qualifier IS NULL
  )
),
inserted_object AS (
    INSERT INTO dspaceobject (uuid)
    SELECT uuid
    FROM tipos
), max_collection_id AS (
  SELECT COALESCE(MAX(collection_id), 0) max_collection_id
  FROM collection
), new_collections AS (
  INSERT INTO collection (
    collection_id,
    uuid
  )
  SELECT
    (SELECT max_collection_id FROM max_collection_id) + ROW_NUMBER() OVER () AS id,
    ti.uuid AS uuid
  FROM tipos AS ti
)
INSERT INTO metadatavalue (metadata_field_id, text_value, text_lang, place, authority, dspace_object_id)
-- Adiciona títulos
SELECT DISTINCT
    (
        SELECT metadata_field_id
        FROM metadatafieldregistry
        WHERE
            metadata_schema_id = (SELECT metadata_schema_id FROM metadataschemaregistry WHERE short_id = 'dc') AND
            element = 'title' AND
            qualifier IS NULL
    ),
    ti.text_value,
    'por',
    0,
    '',
    ti.uuid
FROM tipos ti

UNION

-- Adiciona descrições
SELECT DISTINCT
    (
        SELECT metadata_field_id
        FROM metadatafieldregistry
        WHERE
            metadata_schema_id = (SELECT metadata_schema_id FROM metadataschemaregistry WHERE short_id = 'dc') AND
            element = 'description' AND
            qualifier = 'abstract'
    ),
    '',
    '',
    0,
    '',
    ti.uuid
FROM tipos ti

UNION

-- Adiciona URIs
SELECT DISTINCT
    (
        SELECT metadata_field_id
        FROM metadatafieldregistry
        WHERE
            metadata_schema_id = (SELECT metadata_schema_id FROM metadataschemaregistry WHERE short_id = 'dc') AND
            element = 'identifier' AND
            qualifier = 'uri'
    ),
    CONCAT('http://192.168.1.46:5000/handle/', (SELECT handle FROM handle WHERE resource_id = ti.uuid)),
    '',
    0,
    '',
    ti.uuid
FROM tipos ti
;
