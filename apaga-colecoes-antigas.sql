-- Obs. 1: Não é preciso deletar nada de `epersongroup2eperson` apesar de
-- estarmos deletando de `epersongroup` porque só o grupo de administrador de
-- fato possui eperson's, mas não mexemos nesse grupo.

-- Obs. 2: Não é preciso mexer em `harvested_collection` porque dados harvested
-- não são usados no deposita.

-- Obs. 3: Não é preciso mexer em `process2group` porque essa tabela não possui
-- registros.

-- Obs. 4: Não tenho 100% de certeza se `doi` na coluna `dspace_object` poderia
-- ter coleções normalmente, mas no deposita essa tabela não possui registros.

WITH colecoes_antigas AS (
    SELECT *
    FROM collection
    WHERE uuid NOT IN (SELECT owning_collection FROM item)
), _a AS (
    DELETE FROM community2collection
    WHERE collection_id IN (SELECT uuid FROM colecoes_antigas)
), _b AS (
    DELETE FROM collection2item
    WHERE collection_id IN (SELECT uuid FROM colecoes_antigas)
), _c AS (
    DELETE FROM cwf_collectionrole
    WHERE collection_id IN (SELECT uuid FROM colecoes_antigas)
), _d AS (
    DELETE FROM collection
    WHERE uuid IN (SELECT uuid FROM colecoes_antigas)
), _e AS (
    DELETE FROM handle
    WHERE resource_id IN (SELECT uuid FROM colecoes_antigas)
), _f AS (
    DELETE FROM subscription
    WHERE dspace_object_id IN (SELECT uuid FROM colecoes_antigas)
), _g AS (
    DELETE FROM metadatavalue
    WHERE dspace_object_id IN (SELECT uuid FROM colecoes_antigas)
), nomes_de_grupos_que_devem_ser_excluidos AS (
    SELECT CONCAT('COLLECTION_', collection_id, '_SUBMIT') AS name
    FROM colecoes_antigas

    UNION

    SELECT CONCAT('COLLECTION_', collection_id, '_WORKFLOW_STEP_2') AS name
    FROM colecoes_antigas
), grupos_que_devem_ser_excluidos AS (
    SELECT *
    FROM epersongroup
    WHERE name IN (SELECT name FROM nomes_de_grupos_que_devem_ser_excluidos)
), _i AS (
    DELETE FROM cwf_pooltask
    WHERE group_id IN (SELECT uuid from grupos_que_devem_ser_excluidos)
), _j AS (
    DELETE FROM resourcepolicy
    WHERE
        epersongroup_id IN (SELECT uuid from grupos_que_devem_ser_excluidos) OR
        dspace_object IN (SELECT uuid from colecoes_antigas)
), _k AS (
    DELETE FROM epersongroup
    WHERE uuid IN (SELECT uuid from grupos_que_devem_ser_excluidos)
), _l AS (
    DELETE FROM group2group
    WHERE child_id IN (SELECT uuid FROM grupos_que_devem_ser_excluidos) OR parent_id IN (SELECT uuid FROM grupos_que_devem_ser_excluidos)
), _m AS (
    DELETE FROM group2groupcache
    WHERE child_id IN (SELECT uuid FROM grupos_que_devem_ser_excluidos) OR parent_id IN (SELECT uuid FROM grupos_que_devem_ser_excluidos)
)

DELETE FROM dspaceobject
WHERE uuid IN (SELECT uuid FROM colecoes_antigas)
RETURNING *

;
