SELECT *
FROM metadatavalue
WHERE metadata_field_id = (
  SELECT metadata_field_id
  FROM metadatafieldregistry
  WHERE
    metadata_schema_id = (SELECT metadata_schema_id FROM metadataschemaregistry WHERE short_id = 'dc') AND
    element = 'type' AND
    qualifier IS NULL
);
