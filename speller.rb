require 'sinatra/base'
require 'sinatra/cross_origin'
require 'ffi/aspell'
require 'json'

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
end

# A class used to use aspell to spellcheck a text
class Speller
  def self.check(words, lang, max_suggestions = 10)
    return if words.nil?
    lang = 'es' unless %w(es en pt).include?(lang)
    lang = 'pt_BR' if lang == 'pt'
    speller = FFI::Aspell::Speller.new(lang)
    pos = 0
    words.split.map do |word|
      element = correct_word(speller, word, max_suggestions, pos)
      pos += (word.length + 1)
      element
    end.compact
  end

  def self.correct_word(speller, word, max_suggestions, pos)
    return if speller.correct?(word)
    suggestions = speller.suggestions(word).first(max_suggestions)
    suggestions.map! {|suggestion| suggestion.encode("UTF-8")}
    suggestions_to_hash(word, pos, suggestions)
  end

  def self.suggestions_to_hash(word, pos, suggestions)
    { attrs: { l: word.length, o: pos, s: 1 }, suggestions: suggestions }
  end
end

SpellerApp.run!
