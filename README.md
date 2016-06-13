## Speller

A small sinatra application who provides a text spellcheck service.

## Before start

We use Aspell to provide the spell checker service. You need to install it with
the dictionaries of your choice:

### OSX

```
brew install aspell --with-lang-es --with-lang-en --with-lang-pt-br
```

### Linux

```
sudo apt-get install aspell aspell-en aspell-es aspell-pt-br
```


## Startup!

```
bundle install
ruby speller.rb
```
