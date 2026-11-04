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

## Development with Podman

The compose setup includes Ruby 4.0, Aspell and the es/en/pt_BR
dictionaries, so nothing needs to be installed on the host besides Podman.

```
podman compose up --build -d
curl -X POST localhost:3019/spell -d lang=en --data-urlencode 'text=Helo wrld'
```

The source is mounted into the container and the server restarts a few
seconds after a source file changes, so edits to `speller.rb` apply without a
manual restart. After changing the
`Gemfile`, run `podman compose run --rm speller bundle install` to update
`Gemfile.lock`, then `podman compose up --build -d`.

### VS Code

Ruby LSP runs inside the container, so no Ruby is needed on the host:

1. Install the Dev Containers extension (`ms-vscode-remote.remote-containers`).
2. Add `"dev.containers.dockerPath": "podman"` to your VS Code user settings.
3. Run **Dev Containers: Reopen in Container**.

## Tests

The suite uses Minitest and runs against the real Aspell dictionaries:

```
podman compose run --rm speller bundle exec rake test
```

To get a coverage report in `coverage/index.html`, set `COVERAGE=1`:

```
podman compose run --rm -e COVERAGE=1 speller bundle exec rake test
```

GitHub Actions runs the suite with coverage on every pull request and on
pushes to `master` (`.github/workflows/testing.yml`).

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