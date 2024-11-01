WITH metadado_necessario AS (
    SELECT *
    FROM
    (
        VALUES
            ('dc', 'citation', 'epage'),
            ('dc', 'citation', 'issue'),
            ('dc', 'citation', 'spage'),
            ('dc', 'citation', 'volume'),
            ('dc', 'contributor', 'name'),
            ('dc', 'date', NULL),
            ('dc', 'date', 'issued'),
            ('dc', 'description', NULL),
            ('dc', 'description', 'alternative'),
            ('dc', 'description', 'reference'),
            ('dc', 'description', 'region'),
            ('dc', 'description', 'sponsorship'),
            ('dc', 'identifier', NULL),
            ('dc', 'identifier', 'capes'),
            ('dc', 'identifier', 'citation'),
            ('dc', 'identifier', 'cnpq'),
            ('dc', 'identifier', 'courseurl'),
            ('dc', 'identifier', 'isbn'),
            ('dc', 'identifier', 'isni'),
            ('dc', 'identifier', 'issn'),
            ('dc', 'identifier', 'issnl'),
            ('dc', 'identifier', 'lattes'),
            ('dc', 'identifier', 'orcid'),
            ('dc', 'identifier', 'programurl'),
            ('dc', 'identifier', 'publisherurl'),
            ('dc', 'identifier', 'ror'),
            ('dc', 'identifier', 'url'),
            ('dc', 'identifier', 'urlevent'),
            ('dc', 'identifier', 'urljournal'),
            ('dc', 'identifier', 'wikidata'),
            ('dc', 'knowledgearea', 'capes'),
            ('dc', 'knowledgearea', 'cnpq'),
            ('dc', 'language', NULL),
            ('dc', 'publisher', 'country'),
            ('dc', 'publisher', 'coursedegree'),
            ('dc', 'publisher', 'coursedepartment'),
            ('dc', 'publisher', 'coursename'),
            ('dc', 'publisher', 'coursetype'),
            ('dc', 'publisher', 'event'),
            ('dc', 'publisher', 'juridicnature'),
            ('dc', 'publisher', 'name'),
            ('dc', 'publisher', 'programname'),
            ('dc', 'publisher', 'type'),
            ('dc', 'relation', 'ispartof'),
            ('dc', 'rights', NULL),
            ('dc', 'subject', NULL),
            ('dc', 'subject', 'alternative'),
            ('dc', 'title', NULL),
            ('dc', 'title', 'alternative'),
            ('dc', 'title', 'book'),
            ('dc', 'title', 'journal'),
            ('dc', 'type', NULL)
    ) AS metadado_necessario(schema, element, qualifier)
), metadado_necessario_faltando AS (
    SELECT schema, element, qualifier
    FROM metadado_necessario AS mn
    WHERE get_metadata_field_id(element::TEXT, qualifier::TEXT) IS NULL
)

INSERT INTO metadatafieldregistry (metadata_schema_id, element, qualifier)
SELECT
    (SELECT metadata_schema_id FROM metadataschemaregistry WHERE short_id = mnf.schema) AS metadata_schema_id,
    mnf.element,
    mnf.qualifier
FROM metadado_necessario_faltando AS mnf;
;
