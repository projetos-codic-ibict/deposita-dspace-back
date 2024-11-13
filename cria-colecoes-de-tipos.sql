-- Isto cria uma coleção para cada dc.type com:
--   - dc.title = valor do dc.type
--   - dc.abstract.description = '' (descrição vazia)
--   - dc.identifier.uri = 'http://192.168.1.46:5000/handle/{handle}' ({handle} é deposita/2, deposita/3, etc...)

DO
$$
DECLARE
    tipos RECORD;
    uuid_da_colecao UUID;
    tipo TEXT;
BEGIN
    FOR tipo IN (
        SELECT DISTINCT ON (text_value) text_value
        FROM metadatavalue
        WHERE metadata_field_id = get_metadata_field_id('type', NULL)
    )
    LOOP
        RAISE NOTICE 'Criando coleção para o tipo: %', tipo;
        uuid_da_colecao := (SELECT cria_colecao(tipo));
        RAISE NOTICE 'Coleção % criada', uuid_da_colecao;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
