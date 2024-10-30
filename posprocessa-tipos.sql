DO $$
BEGIN
PERFORM renomeia_metadado_tipo('article', 'Artigo');
PERFORM renomeia_metadado_tipo('conferenceObject', 'Artigo de evento');
PERFORM renomeia_metadado_tipo('bookPart', 'Capítulo de livro');
PERFORM renomeia_metadado_tipo('masterThesis', 'Dissertação');
PERFORM renomeia_metadado_tipo('book', 'Livro');
PERFORM renomeia_metadado_tipo('doctoralThesis', 'Tese');
PERFORM renomeia_metadado_tipo('bachelorThesis', 'Trabalho de conclusão de curso');
END;
$$ LANGUAGE plpgsql;
