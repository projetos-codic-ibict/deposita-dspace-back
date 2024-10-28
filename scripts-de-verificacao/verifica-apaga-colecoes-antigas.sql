-- Obs.: Isso não verifica as partes relacionadas a grupos

SELECT *
FROM (
  SELECT uuid FROM collection

  UNION

  SELECT collection_id AS uuid FROM collection2item

  UNION

  SELECT collection_id AS uuid FROM community2collection

  UNION

  SELECT collection_id AS uuid FROM cwf_collectionrole

  UNION

  SELECT collection_id AS uuid FROM cwf_workflowitem

  UNION

  SELECT collection_id AS uuid FROM harvested_collection

  UNION

  SELECT owning_collection AS uuid FROM item

  UNION

  SELECT collection_id AS uuid FROM workspaceitem

  UNION

  SELECT resource_id as uuid FROM handle

  UNION

  SELECT dspace_object_id as uuid FROM subscription

  UNION

  SELECT dspace_object_id as uuid FROM metadatavalue

  UNION

  SELECT uuid FROM dspaceobject
) AS _
WHERE
  -- Coloca aqui os uuids das coleções antigas
  _.uuid IN (
    '190c682c-65c1-4dec-856b-4051cc39f795',
    '3c0958fe-dc67-40fa-9ee2-2db2545efdde',
    'b241f87d-c33d-4c85-8ff8-1b4aa5bd1761',
    'd151499d-b1a0-4b1d-9492-9ebf72cdef0a',
    'dae9568f-6b83-4e24-9b7f-b4c3a6371314'
  )

;
