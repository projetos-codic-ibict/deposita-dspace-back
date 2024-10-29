WITH nomes as (
  SELECT *
  FROM
  (
    VALUES
      ('Artigo', 'article'),
      ('Artigo de evento', 'conferenceObject'),
      ('Capítulo de livro', 'bookPart'),
      ('Dissertaçaõ', 'masterThesis'),
      ('Dissertação', 'masterThesis'),
      ('mastherThesis', 'masterThesis'),
      ('Livro', 'book'),
      ('Tese', 'doctoralThesis'),
      ('Trabalho de conclusão de curso', 'bachelorThesis')
  )
  as t(nome_antigo, nome_novo)
)
UPDATE metadatavalue
SET text_value = (SELECT nome_novo from nomes where nome_antigo = text_value)
WHERE
  metadata_field_id =
    (
      SELECT metadata_field_id
      FROM metadatafieldregistry
      WHERE
        metadata_schema_id = (SELECT metadata_schema_id FROM metadataschemaregistry WHERE short_id = 'dc')
        AND element = 'type'
        AND qualifier IS NULL
    )
  AND text_value IN (select nome_antigo from nomes)
;
