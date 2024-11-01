-- Adiciona o metadado de região para cada item
INSERT INTO metadatavalue (metadata_field_id, text_value, text_lang, place, authority, dspace_object_id)
SELECT
  (
    SELECT metadata_field_id
    FROM metadatafieldregistry
    WHERE
      metadata_schema_id = (SELECT metadata_schema_id FROM metadataschemaregistry where short_id = 'dc') AND
      element = 'description' AND
      qualifier = 'region'
  ) AS metadata_field_id,
  (
    SELECT text_value FROM metadatavalue
    WHERE dspace_object_id = collection.uuid AND metadata_field_id = get_metadata_field_id('title', NULL)
  ) AS text_value,
  'por' AS text_lang,
  0 AS place,
  '' AS authority,
  item.uuid AS dspace_object_id
FROM
item
JOIN collection ON item.owning_collection = collection.uuid
WHERE item.in_archive = 't';
