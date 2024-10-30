-- O PERFORM é usado em vez de SELECT porque assim não mostra nenhum output
-- desnecessário, mas o SELECT poderia ser usado tranqualimente para evitar o
-- uso de plpgsql.
DO $$
BEGIN
PERFORM renomeia_metadado_tipo('Artigo', 'article');
PERFORM renomeia_metadado_tipo('Artigo de evento', 'conferenceObject');
PERFORM renomeia_metadado_tipo('Capítulo de livro', 'bookPart');
PERFORM renomeia_metadado_tipo('Dissertaçaõ', 'masterThesis');
PERFORM renomeia_metadado_tipo('Dissertação', 'masterThesis');
PERFORM renomeia_metadado_tipo('mastherThesis', 'masterThesis');
PERFORM renomeia_metadado_tipo('Livro', 'book');
PERFORM renomeia_metadado_tipo('Tese', 'doctoralThesis');
PERFORM renomeia_metadado_tipo('Trabalho de conclusão de curso', 'bachelorThesis');
END;
$$ LANGUAGE plpgsql;
