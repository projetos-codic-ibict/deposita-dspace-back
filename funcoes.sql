CREATE OR REPLACE FUNCTION get_metadata_field_id(element_arg TEXT, qualifier_arg TEXT)
RETURNS INTEGER AS $$
DECLARE
    result INTEGER;
BEGIN
    SELECT metadata_field_id
    INTO result
    FROM metadatafieldregistry
    WHERE
        metadata_schema_id = (
            SELECT metadata_schema_id
            FROM metadataschemaregistry
            WHERE short_id = 'dc'
        )
        AND element = element_arg
        AND (qualifier IS NULL AND qualifier_arg IS NULL OR qualifier = qualifier_arg);

    RETURN result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_max_id(tabela TEXT, coluna TEXT)
RETURNS INTEGER AS $$
DECLARE
    result INTEGER;
BEGIN
    EXECUTE format('SELECT COALESCE(MAX(%I), 0) FROM %I', coluna, tabela)
    INTO result;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION renomeia_metadado_tipo(nome_antigo TEXT, nome_novo TEXT)
RETURNS VOID AS $$
BEGIN
  UPDATE metadatavalue
  SET text_value = nome_novo
  WHERE
    metadata_field_id = get_metadata_field_id('type', NULL)
    AND text_value = nome_antigo;
END;
$$ LANGUAGE plpgsql;
