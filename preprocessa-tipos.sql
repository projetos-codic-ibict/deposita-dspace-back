-- 'Livro' -> 'book'
-- 'Dissertaçaõ' -> 'Dissertação'
-- 'Artigo' -> 'article'
-- 'Artigo de evento'
-- 'Capítulo de livro' -> 'bookPart'
-- 'Tese'
-- 'mastherThesis'
-- 'doctoralThesis'
-- 'Trabalho de conclusão de curso' -> 'bachelorThesis'
-- 'conferenceObject'
-- 'other'
-- 'Objetos de aprendizagem'
-- 'Relatório' -> 'report'
-- 'Dados científicos'

WITH nomes as (
  SELECT *
  FROM
  (
    VALUES
      -- OBS.: Acho que isso pode falhar se o nome da esquerda for usado várias
      -- vezes, mas nesse caso não é.
      ('book', 'Livro'),
      ('Dissertaçaõ', 'Dissertação'),
      ('article', 'Artigo'),
      ('bookPart', 'Capítulo de livro'),
      ('bachelorThesis', 'Trabalho de conclusão de curso'),
      ('report', 'Relatório')
  )
  as t (nome_antigo, nome_novo)
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
