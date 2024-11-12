CREATE OR REPLACE FUNCTION cria_colecao()
RETURNS UUID AS $$
DECLARE
    uuid_da_colecao UUID;
    collection_id INTEGER;
BEGIN
    collection_id := get_max_id('collection', 'collection_id') + 1;
    uuid_da_colecao := GEN_RANDOM_UUID();
    -- Cria grupo de submit
    submitter := cria_grupo(CONCAT('COLLECTION_', collection_id, '_SUBMIT'));

    INSERT INTO collection (collection_id, uuid, submitter)
    VALUES (collection_id, uuid, submitter);

    -- Cria grupo de workflow_step
    SELECT cria_grupo(CONCAT('COLLECTION_', collection_id, '_WORKFLOW_STEP_2'));

    RETURN uuid_da_colecao;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cria_grupo(nome TEXT, child_id TEXT)
RETURNS UUID AS $$
DECLARE
    uuid_do_grupo UUID;
BEGIN
    eperson_group_id := (SELECT max_epersongroup_id FROM max_epersongroup_id) + 1;
    uuid_do_grupo := GEN_RANDOM_UUID();
    uuid_do_grupo_anonimo := SELECT uuid FROM epersongroup WHERE name = 'Anonymous';
    uuid_do_grupo_administrador := SELECT uuid FROM epersongroup WHERE name = 'Administrator';

    INSERT INTO epersongroup (eperson_group_id, uuid, permanent, name)
    VALUES (eperson_group_id, uuid_do_grupo, FALSE, nome);

    INSERT INTO group2group (parent_id, child_id) VALUES (uuid_do_grupo, uuid_do_grupo_anonimo);
    INSERT INTO group2groupcache (parent_id, child_id) VALUES (uuid_do_grupo, uuid_do_grupo_anonimo);

    INSERT INTO cwf_collectionrole (collectionrole_id, role_id, collection_id, group_id)
    SELECT
        NEXTVAL('cwf_collectionrole_seq') AS collectionrole_id,
        'editor' AS role_id,
        g.id_da_colecao AS collection_id,
        g.uuid AS group_id
    FROM grupos_de_workflow_step_mais_id_da_colecao AS g

    RETURN uuid_do_grupo;
END;
$$ LANGUAGE plpgsql;
