CREATE OR REPLACE FUNCTION _cria_objeto()
RETURNS UUID AS $$
DECLARE
    uuid_do_objeto UUID;
BEGIN
    uuid_do_objeto := GEN_RANDOM_UUID();

    INSERT INTO dspaceobject (uuid) VALUES (uuid_do_objeto);

    RETURN uuid_do_objeto;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION _cria_grupo_da_colecao(nome TEXT, child_id UUID, uuid_da_colecao UUID)
RETURNS UUID AS $$
DECLARE
    uuid_do_grupo UUID;
    eperson_group_id INTEGER;
BEGIN
    eperson_group_id := (SELECT MAX(epersongroup.eperson_group_id) FROM epersongroup) + 1;
    uuid_do_grupo := _cria_objeto();

    INSERT INTO epersongroup (eperson_group_id, uuid, permanent, name)
    VALUES (eperson_group_id, uuid_do_grupo, FALSE, nome);

    INSERT INTO group2group (parent_id, child_id) VALUES (uuid_do_grupo, child_id);
    INSERT INTO group2groupcache (parent_id, child_id) VALUES (uuid_do_grupo, child_id);

    RETURN uuid_do_grupo;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION _cria_collectionrole(uuid_da_colecao UUID, uuid_do_grupo_de_workflow_step UUID)
RETURNS VOID AS $$
BEGIN
    INSERT INTO cwf_collectionrole (collectionrole_id, role_id, collection_id, group_id)
    VALUES (
        NEXTVAL('cwf_collectionrole_seq'),
        'editor',
        uuid_da_colecao,
        uuid_do_grupo_de_workflow_step
    );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION _cria_resourcepolicy(resource_id INTEGER, action_id INTEGER, epersongroup_id UUID, dspace_object UUID)
RETURNS INTEGER AS $$
DECLARE
    id_da_politica INTEGER;
BEGIN
    id_da_politica := NEXTVAL('resourcepolicy_seq');

    INSERT INTO resourcepolicy (policy_id, resource_type_id, resource_id, action_id, epersongroup_id, dspace_object)
    VALUES (
        id_da_politica,
        -- Esta constante é definida no código, em dspace-api/src/main/java/org/dspace/core/Constants.java
        3,
        resource_id,
        action_id,
        epersongroup_id,
        dspace_object
    );

    RETURN id_da_politica;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION _cria_handle(uuid_da_colecao UUID, id_da_colecao INTEGER)
RETURNS TEXT AS $$
DECLARE
    uuid_do_grupo UUID;
    handle TEXT;
BEGIN
    handle := CONCAT('deposita/', NEXTVAL('handle_seq'));

    INSERT INTO handle
    VALUES (
        NEXTVAL('handle_id_seq'),
        handle,
        -- Esta constante é definida no código, em dspace-api/src/main/java/org/dspace/core/Constants.java
        3,
        id_da_colecao,
        uuid_da_colecao
    );

    RETURN handle;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION _cria_metadados_da_colecao(nome TEXT, uuid_da_colecao UUID, handle TEXT)
RETURNS VOID AS $$
DECLARE
    title_field_id INTEGER;
    abstract_field_id INTEGER;
    uri_field_id INTEGER;
    uri TEXT;
BEGIN
    title_field_id := get_metadata_field_id('title', NULL);
    abstract_field_id := get_metadata_field_id('description', 'abstract');
    uri_field_id := get_metadata_field_id('identifier', 'uri');
    uri := CONCAT('http://192.168.1.46:5000/handle/', handle);

    -- Adiciona títulos
    INSERT INTO metadatavalue (metadata_field_id, text_value, text_lang, place, authority, dspace_object_id)
    VALUES (title_field_id, nome, 'por', 0, '', uuid_da_colecao);

    -- Adiciona descrições
    INSERT INTO metadatavalue (metadata_field_id, text_value, text_lang, place, authority, dspace_object_id)
    VALUES (abstract_field_id, '', '', 0, '', uuid_da_colecao);

    -- Adiciona URIs
    INSERT INTO metadatavalue (metadata_field_id, text_value, text_lang, place, authority, dspace_object_id)
    VALUES (uri_field_id, uri, '', 0, '', uuid_da_colecao);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cria_colecao(nome TEXT)
RETURNS UUID AS $$
DECLARE
    uuid_da_colecao UUID;
    collection_id INTEGER;
    submitter UUID;
    handle TEXT;
    uuid_do_grupo_de_workflow_step UUID;
    uuid_do_grupo_anonimo UUID;
    uuid_do_grupo_administrador UUID;
    uuid_da_comunidade UUID;
    action_id INTEGER;
BEGIN
    -- deposita só tem 1 comunidade
    uuid_da_comunidade := (SELECT uuid FROM community LIMIT 1);
    SELECT uuid INTO uuid_do_grupo_anonimo FROM epersongroup WHERE name = 'Anonymous';
    SELECT uuid INTO uuid_do_grupo_administrador FROM epersongroup WHERE name = 'Administrator';
    collection_id := get_max_id('collection', 'collection_id') + 1;
    uuid_da_colecao := _cria_objeto();
    -- Cria grupo de submit
    submitter := _cria_grupo_da_colecao(CONCAT('COLLECTION_', collection_id, '_SUBMIT'), uuid_do_grupo_anonimo, uuid_da_colecao);

    INSERT INTO collection (collection_id, uuid, submitter)
    VALUES (collection_id, uuid_da_colecao, submitter);

    uuid_do_grupo_de_workflow_step := _cria_grupo_da_colecao(CONCAT('COLLECTION_', collection_id, '_WORKFLOW_STEP_2'), uuid_do_grupo_administrador, uuid_da_colecao);

    PERFORM _cria_collectionrole(uuid_da_colecao, uuid_do_grupo_de_workflow_step);

    FOREACH action_id IN ARRAY ARRAY[0, 10, 9, 3, 3] LOOP
        PERFORM _cria_resourcepolicy(collection_id, action_id, uuid_do_grupo_anonimo, uuid_da_colecao);
    END LOOP;

    INSERT INTO community2collection (collection_id, community_id) VALUES (uuid_da_colecao, uuid_da_comunidade);

    handle := _cria_handle(uuid_da_colecao, collection_id);

    PERFORM _cria_metadados_da_colecao(nome, uuid_da_colecao, handle);

    RETURN uuid_da_colecao;
END;
$$ LANGUAGE plpgsql;
