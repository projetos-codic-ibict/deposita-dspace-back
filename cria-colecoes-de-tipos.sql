-- Isto cria uma coleção para cada dc.type com:
--   - dc.title = valor do dc.type
--   - dc.abstract.description = '' (descrição vazia)
--   - dc.identifier.uri = 'http://192.168.1.46:5000/handle/{handle}' ({handle} é deposita/2, deposita/3, etc...)

WITH tipos AS (
  SELECT DISTINCT ON (text_value) text_value, (GEN_RANDOM_UUID()) uuid
  FROM metadatavalue
  WHERE metadata_field_id = get_metadata_field_id('type', NULL)
),

uuids_das_colecoes AS (INSERT INTO dspaceobject (uuid) SELECT uuid FROM tipos),

max_epersongroup_id AS (SELECT get_max_id('epersongroup', 'eperson_group_id') max_epersongroup_id),

max_collection_id AS (SELECT get_max_id('collection', 'collection_id') max_collection_id),

max_collectionrole_id AS (SELECT get_max_id('cwf_collectionrole', 'collectionrole_id') max_collectionrole_id),

novas_colecoes AS (
  INSERT INTO collection (
    collection_id,
    uuid
  )
  SELECT
    (SELECT max_collection_id FROM max_collection_id) + ROW_NUMBER() OVER () AS id,
    ti.uuid AS uuid
  FROM tipos AS ti
  RETURNING *, GEN_RANDOM_UUID() AS id_do_grupo_de_submit, GEN_RANDOM_UUID() AS id_do_grupo_de_workflow_step
),

uuids_dos_grupos_de_submit AS (
    INSERT INTO dspaceobject (uuid)
    SELECT id_do_grupo_de_submit
    FROM novas_colecoes
),

uuids_dos_grupos_de_workflow_step AS (
    INSERT INTO dspaceobject (uuid)
    SELECT id_do_grupo_de_workflow_step
    FROM novas_colecoes
),

_insere_metadados_das_novas_colecoes AS (
    INSERT INTO metadatavalue (metadata_field_id, text_value, text_lang, place, authority, dspace_object_id)
    -- Adiciona títulos
    SELECT DISTINCT get_metadata_field_id('title', NULL), ti.text_value, 'por', 0, '', ti.uuid
    FROM tipos ti

    UNION

    -- Adiciona descrições
    SELECT DISTINCT get_metadata_field_id('description', 'abstract'), '', '', 0, '', ti.uuid
    FROM tipos ti

    UNION

    -- Adiciona URIs
    SELECT DISTINCT
        get_metadata_field_id('identifier', 'uri'),
        CONCAT('http://192.168.1.46:5000/handle/', (SELECT handle FROM handle WHERE resource_id = ti.uuid)),
        '',
        0,
        '',
        ti.uuid
    FROM tipos ti
),

_insere_grupos_de_submit AS (
    INSERT INTO epersongroup (eperson_group_id, uuid, permanent, name)
    SELECT
        (SELECT max_epersongroup_id FROM max_epersongroup_id) + ROW_NUMBER() OVER () AS eperson_group_id,
        nc.id_do_grupo_de_submit AS uuid,
        FALSE AS permanent,
        CONCAT('COLLECTION_', nc.collection_id, '_SUBMIT') AS name
    FROM novas_colecoes nc
),

dados_epersongroup_mais_id_da_colecao AS (
    SELECT
        (SELECT max_epersongroup_id FROM max_epersongroup_id) + ROW_NUMBER() OVER () AS eperson_group_id,
        nc.id_do_grupo_de_workflow_step AS uuid,
        FALSE AS permanent,
        CONCAT('COLLECTION_', nc.collection_id, '_WORKFLOW_STEP_2') AS name,
        nc.uuid AS id_da_colecao
    FROM novas_colecoes nc
),

_insere_grupos_de_workflow_step AS (
    INSERT INTO epersongroup (eperson_group_id, uuid, permanent, name)
    SELECT eperson_group_id, uuid, permanent, name
    FROM dados_epersongroup_mais_id_da_colecao
)

-- _insere_collection_role AS (
    INSERT INTO cwf_collectionrole (collectionrole_id, role_id, collection_id, group_id)
    SELECT
        (SELECT max_collectionrole_id FROM max_collectionrole_id) + ROW_NUMBER() OVER () AS collectionrole_id,
        'editor' AS role_id,
        dados_epersongroup_mais_id_da_colecao.id_da_colecao AS collection_id,
        dados_epersongroup_mais_id_da_colecao.uuid AS group_id
    FROM dados_epersongroup_mais_id_da_colecao


;
