-- Isto cria uma coleção para cada dc.type com:
--   - dc.title = valor do dc.type
--   - dc.abstract.description = '' (descrição vazia)
--   - dc.identifier.uri = 'http://192.168.1.46:5000/handle/{handle}' ({handle} é deposita/2, deposita/3, etc...)

WITH tipos AS (
  SELECT DISTINCT ON (text_value) text_value, (GEN_RANDOM_UUID()) uuid
  FROM metadatavalue
  WHERE metadata_field_id = get_metadata_field_id('type', NULL)
),

uuids_das_colecoes AS (INSERT INTO dspaceobject (uuid) SELECT uuid FROM tipos RETURNING *),

-- Não existem tabelas de sequência para `epersongroup_id` e `collection_id`
max_epersongroup_id AS (SELECT get_max_id('epersongroup', 'eperson_group_id') AS max_epersongroup_id),
max_collection_id AS (SELECT get_max_id('collection', 'collection_id') AS max_collection_id),

novas_colecoes AS (
  SELECT
    (SELECT max_collection_id FROM max_collection_id) + ROW_NUMBER() OVER () AS collection_id,
    ti.uuid AS uuid,
    GEN_RANDOM_UUID() AS id_do_grupo_de_submit,
    GEN_RANDOM_UUID() AS id_do_grupo_de_workflow_step
  FROM tipos AS ti
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

grupos_de_submit_mais_id_da_colecao AS (
    SELECT
        (SELECT max_epersongroup_id FROM max_epersongroup_id) + ROW_NUMBER() OVER () AS eperson_group_id,
        nc.id_do_grupo_de_submit AS uuid,
        FALSE AS permanent,
        CONCAT('COLLECTION_', nc.collection_id, '_SUBMIT') AS name,
        nc.uuid AS id_da_colecao
    FROM novas_colecoes AS nc
),

grupos_de_workflow_step_mais_id_da_colecao AS (
    SELECT
        (SELECT max_epersongroup_id FROM max_epersongroup_id) + ROW_NUMBER() OVER () AS eperson_group_id,
        nc.id_do_grupo_de_workflow_step AS uuid,
        FALSE AS permanent,
        CONCAT('COLLECTION_', nc.collection_id, '_WORKFLOW_STEP_2') AS name,
        nc.uuid AS id_da_colecao
    FROM novas_colecoes AS nc
),

_insere_grupos_de_submit_e_workflow_step AS (
    INSERT INTO epersongroup (eperson_group_id, uuid, permanent, name)
    SELECT eperson_group_id, uuid, permanent, name
    FROM (
        SELECT eperson_group_id, uuid, permanent, name, 1 AS source_order FROM grupos_de_submit_mais_id_da_colecao
        UNION ALL
        SELECT eperson_group_id, uuid, permanent, name, 2 AS source_order FROM grupos_de_workflow_step_mais_id_da_colecao
    ) AS combined
    ORDER BY eperson_group_id, source_order
    RETURNING *
),

_insere_novas_colecoes AS (
    INSERT INTO collection (collection_id, uuid, submitter)
    SELECT collection_id, uuid, id_do_grupo_de_submit AS submitter FROM novas_colecoes
),

uuid_do_grupo_anonimo AS (
    SELECT uuid FROM epersongroup WHERE name = 'Anonymous'
),

uuid_do_grupo_administrador AS (
    SELECT uuid FROM epersongroup WHERE name = 'Administrator'
),

grupos_de_submit_em_group2group AS (
    INSERT INTO group2group (parent_id, child_id)
    SELECT
        uuid AS parent_id,
        (SELECT uuid FROM uuid_do_grupo_anonimo) AS child_id
    FROM grupos_de_submit_mais_id_da_colecao
    RETURNING *
),

_insere_grupos_de_submit_em_group2group_cache AS (
    INSERT INTO group2groupcache (parent_id, child_id)
    SELECT *
    FROM grupos_de_submit_em_group2group
),

grupos_de_workflow_step_em_group2group AS (
    INSERT INTO group2group (parent_id, child_id)
    SELECT
        uuid AS parent_id,
        (SELECT uuid FROM uuid_do_grupo_administrador) AS child_id
    FROM grupos_de_workflow_step_mais_id_da_colecao
    RETURNING *
),

_insere_grupos_de_workflow_step_em_group2groupcache AS (
    INSERT INTO group2groupcache (parent_id, child_id)
    SELECT *
    FROM grupos_de_workflow_step_em_group2group
),

_insere_collection_role AS (
    INSERT INTO cwf_collectionrole (collectionrole_id, role_id, collection_id, group_id)
    SELECT
        NEXTVAL('cwf_collectionrole_seq') AS collectionrole_id,
        'editor' AS role_id,
        g.id_da_colecao AS collection_id,
        g.uuid AS group_id
    FROM grupos_de_workflow_step_mais_id_da_colecao AS g
),

action_id_epersongroup_id AS (
    SELECT *
    FROM (
        VALUES
            (0, (SELECT uuid FROM uuid_do_grupo_anonimo)),
            (10, (SELECT uuid FROM uuid_do_grupo_anonimo)),
            (9, (SELECT uuid FROM uuid_do_grupo_anonimo)),
            (3, (SELECT uuid FROM uuid_do_grupo_administrador)),
            (3, (SELECT uuid FROM uuid_do_grupo_administrador))
    ) AS action_id(action_id, epersongroup_id)
),

_insere_resource_policy AS (
    INSERT INTO resourcepolicy (policy_id, resource_type_id, resource_id, action_id, epersongroup_id, dspace_object)
    SELECT
        NEXTVAL('resourcepolicy_seq') AS policy_id,
        -- Esta constante é definida no código, em dspace-api/src/main/java/org/dspace/core/Constants.java
        3 AS resource_type_id,
        (SELECT collection_id FROM novas_colecoes WHERE uuid = uc.uuid) AS resource_id,
        action_id_epersongroup_id.action_id,
        action_id_epersongroup_id.epersongroup_id,
        uc.uuid AS dspace_object -- uuid da coleção
    FROM uuids_das_colecoes AS uc
    JOIN action_id_epersongroup_id
    ON TRUE
),

___ AS (
    INSERT INTO community2collection
    SELECT
    nc.uuid AS collection_id,
    (
        SELECT uuid
        FROM community
        LIMIT 1 -- deposita só tem 1 comunidade
    ) AS community_id
    FROM novas_colecoes AS nc
)

INSERT INTO handle
SELECT
    NEXTVAL('handle_id_seq') AS handle_id,
    CONCAT('deposita/', NEXTVAL('handle_seq')) AS handle,
    -- Esta constante é definida no código, em dspace-api/src/main/java/org/dspace/core/Constants.java
    3 AS resource_type_id,
    NULL AS resource_legacy_id,
    nc.uuid AS resource_id
FROM novas_colecoes AS nc

;
