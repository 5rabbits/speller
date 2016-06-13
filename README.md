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

## Endpoints

To consume the service, you could post ```[ROOT_URL]/spell``` endpoint, with the following params:

- text: Is the text you want to spellcheck.
- lang: Is the code of the lang who are you testing text, for example ```es```.

So, a full request could be:

```[ROOT_URL]/spell?lang=en&text=Bla%20Bla%20Bla%20Bla```

The response will be an array of possible suggestions:


```
#!json

[
	{
		"attrs": {
			"l": 3,
			"o": 0,
			"s": 1
		},
		"suggestions": ["Bela", "Blah", "Bola", "Bl", "Blab", "Blag", "Blat", "BA", "Ba", "LA"]
	},
	{
		"attrs": {
			"l": 3,
			"o": 4,
			"s": 1
		},
		"suggestions": ["Bela", "Blah", "Bola", "Bl", "Blab", "Blag", "Blat", "BA", "Ba", "LA"]
	}, {
		"attrs": {
			"l": 3,
			"o": 8,
			"s": 1
		},
		"suggestions": ["Bela", "Blah", "Bola", "Bl", "Blab", "Blag", "Blat", "BA", "Ba", "LA"]
	}, {
		"attrs": {
			"l": 3,
			"o": 12,
			"s": 1
		},
		"suggestions": ["Bela", "Blah", "Bola", "Bl", "Blab", "Blag", "Blat", "BA", "Ba", "LA"]
	}
]
```