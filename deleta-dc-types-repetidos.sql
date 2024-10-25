WITH uuids_dos_tipos_que_repetem AS (
  SELECT dspace_object_id
  FROM (
    SELECT dspace_object_id, count(*)
    FROM metadatavalue
    WHERE metadata_field_id = get_metadata_field_id('type', NULL)
    GROUP BY dspace_object_id
  ) AS _
  WHERE count > 1
),

todos_os_tipos_que_repetem AS (
  SELECT *
  FROM metadatavalue
  WHERE
    metadata_field_id = get_metadata_field_id('type', NULL) AND
    dspace_object_id IN (select dspace_object_id from uuids_dos_tipos_que_repetem)
),

tipos_necessarios AS (
  SELECT DISTINCT ON (text_value) *
  FROM todos_os_tipos_que_repetem
),

tipos_desnecessarios AS (
  SELECT *
  FROM todos_os_tipos_que_repetem
  WHERE
    todos_os_tipos_que_repetem.metadata_value_id NOT IN (SELECT metadata_value_id FROM tipos_necessarios)
)

DELETE
FROM metadatavalue
WHERE metadata_value_id IN (SELECT metadata_value_id FROM tipos_desnecessarios)
;
