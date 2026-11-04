require 'test_helper'

class SpellerTest < Minitest::Test
  def test_ensure_lang_keeps_supported_languages
    assert_equal 'es', Speller.ensure_lang('es')
    assert_equal 'en', Speller.ensure_lang('en')
  end

  def test_ensure_lang_maps_pt_to_pt_br_dictionary
    assert_equal 'pt_BR', Speller.ensure_lang('pt')
  end

  def test_ensure_lang_falls_back_to_es
    assert_equal 'es', Speller.ensure_lang('fr')
    assert_equal 'es', Speller.ensure_lang(nil)
  end

  def test_clean_word_strips_leading_and_trailing_punctuation
    assert_equal 'hola', Speller.clean_word('hola,')
    assert_equal 'qué', Speller.clean_word('¿qué?')
    assert_equal 'hola', Speller.clean_word('(hola)')
  end

  def test_clean_word_keeps_inner_punctuation
    assert_equal "don't", Speller.clean_word("don't")
  end

  def test_clean_word_strips_repeated_punctuation
    assert_equal 'hola', Speller.clean_word('hola...')
    assert_equal 'hola', Speller.clean_word('¡¡hola!!')
    assert_equal 'qué', Speller.clean_word('"¿qué?"')
  end

  def test_clean_word_returns_empty_for_punctuation_only
    assert_equal '', Speller.clean_word('...')
  end

  def test_check_returns_nil_without_text
    assert_nil Speller.check(nil, 'es')
  end

  def test_check_returns_empty_list_when_every_word_is_correct
    assert_equal [], Speller.check('El perro come pan', 'es')
  end

  def test_check_reports_misspelled_word_with_position_and_suggestions
    result = Speller.check('Esto es una prueva', 'es')

    assert_equal 1, result.size
    assert_equal({ l: 6, o: 12, s: 1 }, result.first[:attrs])
    assert_includes result.first[:suggestions], 'prueba'
  end

  def test_check_offsets_point_at_cleaned_word
    result = Speller.check('Hola ¿cmo estás?', 'es')

    assert_equal 1, result.size
    assert_equal({ l: 3, o: 6, s: 1 }, result.first[:attrs])
    assert_includes result.first[:suggestions], 'como'
  end

  def test_check_offsets_survive_repeated_whitespace
    text = "Hola  mundo\n\nprueva\tcmo"

    assert_equal [13, 20], offsets(text)
    assert_equal %w[prueva cmo], flagged(text)
  end

  def test_check_offsets_survive_leading_whitespace
    assert_equal [2], offsets('  prueva')
  end

  def test_check_offsets_skip_surrounding_punctuation
    assert_equal ['prueva'], flagged('Dijo: «prueva»,')
  end

  def test_check_ignores_tokens_that_are_only_punctuation
    assert_equal [], Speller.check('Hola - mundo ...', 'es')
  end

  def test_check_ignores_repeated_punctuation
    assert_equal [], Speller.check('Bueno... sí', 'es')
    assert_equal [], Speller.check('¡¡Hola!!', 'es')
  end

  def test_check_returns_empty_list_for_blank_text
    assert_equal [], Speller.check('', 'es')
    assert_equal [], Speller.check("  \n", 'es')
  end

  def test_check_returns_ten_suggestions_by_default
    assert_equal 10, Speller.check('prueva', 'es').first[:suggestions].size
  end

  def test_check_accepts_custom_suggestion_limit
    assert_equal 3, Speller.check('prueva', 'es', 3).first[:suggestions].size
  end

  def test_check_uses_each_language_dictionary
    assert_equal [], Speller.check('Hello world', 'en')
    assert_equal [], Speller.check('Olá mundo', 'pt')
    refute_empty Speller.check('Hello', 'es')
  end

  def test_check_falls_back_to_spanish_for_unknown_languages
    assert_includes Speller.check('prueva', 'fr').first[:suggestions], 'prueba'
  end

  def test_check_accepts_correctly_spelled_accented_words
    assert_equal [], Speller.check('El corazón late con pasión', 'es')
    assert_equal [], Speller.check('O coração é um órgão', 'pt')
  end

  def test_check_returns_accented_suggestions_as_valid_utf8
    spanish = Speller.check('corazon', 'es').first[:suggestions]
    portuguese = Speller.check('coracao', 'pt').first[:suggestions]

    assert_includes spanish, 'corazón'
    assert_includes portuguese, 'coração'
    (spanish + portuguese).each do |suggestion|
      assert_equal Encoding::UTF_8, suggestion.encoding
      assert suggestion.valid_encoding?, "#{suggestion.inspect} is not valid UTF-8"
    end
  end

  def test_check_ignores_encoding_from_aspell_environment
    previous = ENV['ASPELL_CONF']
    ENV['ASPELL_CONF'] = 'encoding iso-8859-1'

    assert_equal [], Speller.check('corazón', 'es')
    assert_includes Speller.check('corazon', 'es').first[:suggestions], 'corazón'
  ensure
    ENV['ASPELL_CONF'] = previous
  end

  private

  def offsets(text, lang = 'es')
    Speller.check(text, lang).map { |entry| entry[:attrs][:o] }
  end

  # The slice of text each result points at, as a client would highlight it
  def flagged(text, lang = 'es')
    Speller.check(text, lang).map { |entry| text[entry[:attrs][:o], entry[:attrs][:l]] }
  end
end
