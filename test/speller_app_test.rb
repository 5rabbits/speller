require 'test_helper'

class SpellerAppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    SpellerApp
  end

  def json_body
    JSON.parse(last_response.body)
  end

  def test_post_returns_misspelled_words_as_json
    post '/spell', text: 'Helo world', lang: 'en'

    assert last_response.ok?
    assert_equal 1, json_body.size
    assert_equal({ 'l' => 4, 'o' => 0, 's' => 1 }, json_body.first['attrs'])
    assert_includes json_body.first['suggestions'], 'Hello'
  end

  def test_post_accepts_params_in_query_string
    post '/spell?lang=en&text=Helo'

    assert_includes json_body.first['suggestions'], 'Hello'
  end

  def test_post_handles_accented_form_input
    post '/spell', text: 'El corazón late, corazon', lang: 'es'

    assert_equal 1, json_body.size
    assert_equal({ 'l' => 7, 'o' => 17, 's' => 1 }, json_body.first['attrs'])
    assert_includes json_body.first['suggestions'], 'corazón'
  end

  def test_post_offsets_count_newlines_in_form_input
    post '/spell', text: "Hola\n\nprueva", lang: 'es'

    assert_equal({ 'l' => 6, 'o' => 6, 's' => 1 }, json_body.first['attrs'])
  end

  def test_post_returns_null_without_text
    post '/spell', lang: 'es'

    assert last_response.ok?
    assert_equal 'null', last_response.body
  end

  def test_post_allows_any_origin
    post '/spell', { text: 'hola', lang: 'es' }, 'HTTP_ORIGIN' => 'http://example.com'

    assert_equal 'http://example.com', last_response.headers['Access-Control-Allow-Origin']
  end

  def test_options_answers_cors_preflight
    options '/spell', {}, 'HTTP_ORIGIN' => 'http://example.com'

    assert last_response.ok?
    assert_empty last_response.body
    expected = {
      'Access-Control-Allow-Origin' => 'http://example.com',
      'Access-Control-Allow-Methods' => 'POST, GET, OPTIONS',
      'Access-Control-Allow-Headers' => '*, Content-Type, Accept, AUTHORIZATION, Cache-Control',
      'Access-Control-Allow-Credentials' => 'true',
      'Access-Control-Max-Age' => '1728000',
      'Access-Control-Expose-Headers' =>
        'Cache-Control, Content-Language, Content-Type, Expires, Last-Modified, Pragma'
    }
    expected.each do |name, value|
      assert_equal value, last_response.headers[name], name
    end
  end

  def test_no_cors_headers_without_origin
    post '/spell', text: 'hola', lang: 'es'

    assert_nil last_response.headers['Access-Control-Allow-Origin']
  end

  def test_get_is_not_routed
    get '/spell', text: 'hola', lang: 'es'

    assert_equal 404, last_response.status
  end
end
