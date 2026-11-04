require 'sinatra/base'
require 'ffi/aspell'
require 'json'

# Sinatra app for check spelling
class SpellerApp < Sinatra::Base
  # Sent with every request that carries an Origin, which is echoed back so
  # any site can call the service.
  CORS_HEADERS = {
    'Access-Control-Allow-Methods' => 'POST, GET, OPTIONS',
    'Access-Control-Allow-Headers' => '*, Content-Type, Accept, AUTHORIZATION, Cache-Control',
    'Access-Control-Allow-Credentials' => 'true',
    'Access-Control-Max-Age' => '1728000',
    'Access-Control-Expose-Headers' =>
      'Cache-Control, Content-Language, Content-Type, Expires, Last-Modified, Pragma'
  }.freeze

  configure do
    set :bind, '0.0.0.0'
  end

  # Sinatra 4.1+ rejects unknown Host headers in development (e.g. another
  # container calling http://speller:3019). Disabled for now; other
  # environments already accept any host.
  configure :development do
    set :host_authorization, permitted_hosts: []
  end

  before do
    origin = request.env['HTTP_ORIGIN']
    headers CORS_HEADERS.merge('Access-Control-Allow-Origin' => origin) if origin
  end

  post '/spell' do
    Speller.check(params[:text], params[:lang]).to_json
  end

  options '/spell' do
    ''
  end
end

# A class used to use aspell to spellcheck a text
class Speller
  LEADING_PUNCTUATION = /\A[[:punct:]]*/
  TRAILING_PUNCTUATION = /[[:punct:]]*\z/

  def self.check(text, lang, max_suggestions = 10)
    return if text.nil?

    lang = ensure_lang(lang)
    # Pin aspell to UTF-8 for input and output instead of inheriting it from
    # the process locale. It must be set before the language: ffi-aspell
    # applies options in hash order, and with no locale the default encoding
    # is "none", which crashes ffi-aspell.
    speller = FFI::Aspell::Speller.new(lang, 'encoding' => 'utf-8')

    words(text).filter_map do |word, pos|
      correct_word(speller, word, max_suggestions, pos)
    end
  end

  # Each whitespace-separated token of text with its surrounding punctuation
  # removed, paired with the character offset where that cleaned word starts,
  # so text[pos, word.length] == word. Punctuation-only tokens are skipped.
  def self.words(text)
    text.enum_for(:scan, /\S+/).filter_map do
      match = Regexp.last_match
      word = clean_word(match[0])
      next if word.empty?

      [word, match.begin(0) + match[0][LEADING_PUNCTUATION].length]
    end
  end

  def self.ensure_lang(lang)
    lang = 'es' unless %w[es en pt].include?(lang)
    lang = 'pt_BR' if lang == 'pt'
    lang
  end

  def self.clean_word(word)
    word.sub(LEADING_PUNCTUATION, '').sub(TRAILING_PUNCTUATION, '')
  end

  def self.correct_word(speller, word, max_suggestions, pos)
    return if speller.correct?(word)

    suggestions = speller.suggestions(word).first(max_suggestions)
    suggestions_to_hash(word, pos, suggestions)
  end

  def self.suggestions_to_hash(word, pos, suggestions)
    { attrs: { l: word.length, o: pos, s: 1 }, suggestions: suggestions }
  end
end

SpellerApp.run! if __FILE__ == $PROGRAM_NAME
