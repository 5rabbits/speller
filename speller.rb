require 'sinatra/base'
require 'sinatra/cross_origin'
require 'ffi/aspell'
require 'json'

# Sinatra app for check spelling
class SpellerApp < Sinatra::Base
  register Sinatra::CrossOrigin

  configure do
    set :allow_origin, :any
    set :bind, '0.0.0.0'
    enable :cross_origin
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
  def self.check(words, lang, max_suggestions = 10)
    return if words.nil?

    lang = ensure_lang(lang)
    speller = FFI::Aspell::Speller.new(lang)

    pos = 0
    words.split.map do |word|
      element = correct_word(speller, clean_word(word), max_suggestions, pos)
      pos += (word.length + 1)
      element
    end.compact
  end

  def self.ensure_lang(lang)
    lang = 'es' unless %w[es en pt].include?(lang)
    lang = 'pt_BR' if lang == 'pt'
    lang
  end

  def self.clean_word(word)
    word.gsub(/^[[:punct:]]/,'')
        .gsub(/[[:punct:]]$/,'')
  end

  def self.correct_word(speller, word, max_suggestions, pos)
    return if speller.correct?(word)

    suggestions = speller.suggestions(word).first(max_suggestions)
    suggestions.map! do |suggestion|
      suggestion.force_encoding('ISO-8859-1').encode('UTF-8')
    end
    suggestions_to_hash(word, pos, suggestions)
  end

  def self.suggestions_to_hash(word, pos, suggestions)
    { attrs: { l: word.length, o: pos, s: 1 }, suggestions: suggestions }
  end
end

SpellerApp.run!
