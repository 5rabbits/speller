# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Single-file Sinatra service (`speller.rb`) that exposes Aspell spellchecking over HTTP. Ruby 4.0 (`.ruby-version`, enforced by the Gemfile and duplicated in the `Dockerfile` `FROM` line; keep both in sync), Sinatra 4.2 on Rack 3, Puma, `ffi-aspell` 1.1.

## Commands

Preferred: the Podman compose dev environment (`compose.yaml` + `Dockerfile`), which bundles Ruby, Aspell and the es/en/pt_BR dictionaries:

```
podman compose up --build -d        # serves on localhost:3019
podman compose logs -f
curl -X POST localhost:3019/spell -d 'lang=en' --data-urlencode 'text=Helo wrld'
podman compose run --rm speller bundle install   # after editing Gemfile (writes Gemfile.lock), then up --build
podman compose run --rm speller irb -r ./speller # console with Speller loaded
```

The repo is bind-mounted at `/app` and `rerun` restarts `rackup` (Puma) when a source file changes, within a few seconds. It must use `--force-polling` because host file events don't reach the container through the podman machine mount. Gemfile changes need a rebuild.

VS Code: `.devcontainer/devcontainer.json` attaches to the same compose container (`name: speller` in `compose.yaml` keeps Dev Containers from starting a second one on port 3019), and Ruby LSP runs there. `ruby-lsp` and `debug` are in the Gemfile's development group so the image already has them and Ruby LSP skips its composed bundle. Nothing Ruby-related is installed on the host. Dev Containers needs `"dev.containers.dockerPath": "podman"` in the user's VS Code settings.

Without containers, Aspell plus dictionaries must be installed on the host (`ffi-aspell` loads the native library at runtime). See README. Then `bundle install && ruby speller.rb` (port 4567).

Tests use Minitest + rack-test (`test/`) and need real Aspell dictionaries, so run them in the container:

```
podman compose run --rm speller bundle exec rake test                               # whole suite
podman compose run --rm speller bundle exec rake test TEST=test/speller_app_test.rb  # one file
podman compose run --rm speller bundle exec ruby -Itest test/speller_test.rb -n test_check_returns_nil_without_text  # one test
```

There is no linter config.

## Architecture

`speller.rb` holds two classes. `SpellerApp.run!` only fires when the file is executed directly (port 4567, or `PORT`); `config.ru` mounts `SpellerApp` for `rackup`, and requiring `speller.rb` does not boot a server.

- `SpellerApp` (modular `Sinatra::Base`): `POST /spell` with `text` and `lang` params (form body or query string), plus `OPTIONS /spell` for CORS preflight. There is no GET route. CORS is hand-rolled in a `before` filter: when a request carries `Origin`, it is echoed back along with `CORS_HEADERS`. These values match what the old `sinatra-cross_origin` gem sent, and `test_options_answers_cors_preflight` pins them.
- **Host authorization (Sinatra 4.1+):** by default, Sinatra 403s requests in `development` whose `Host` isn't `localhost`, `*.localhost`, `*.test` or an IP. `SpellerApp` turns that off (`permitted_hosts: []` in `configure :development`), so any host is accepted in every environment. This is a deliberate, temporary choice to revisit later. The tests run as `test`, so they don't cover this setting.
- `Speller.check(text, lang)`: builds a fresh `FFI::Aspell::Speller` per request. `Speller.words` scans whitespace-separated tokens, strips all leading and trailing punctuation (punctuation-only tokens are skipped), and keeps each cleaned word's offset. `check` returns only misspelled words. Returns `nil` (JSON `null`) when `text` is missing.

Behavior that is easy to break:

- **Languages:** only `es`, `en`, `pt` are accepted; anything else silently falls back to `es`. `pt` maps to the `pt_BR` Aspell dictionary.
- **Response shape:** `{ attrs: { l:, o:, s: 1 }, suggestions: [...] }`, at most 10 suggestions. `o` is the character offset (not byte) of the cleaned word in the original text and `l` is its length, so `text[o, l]` is exactly the flagged word, whatever whitespace or punctuation surrounds it. `s` is always `1`. The `flagged` helper in `test/speller_test.rb` asserts this. Clients rely on this shape.
- **Encoding:** `Speller.check` creates the speller with `'encoding' => 'utf-8'`, so input and suggestions are UTF-8 whatever the locale or `ASPELL_CONF` say. The option must stay ahead of the language: ffi-aspell applies options in hash order, and with no locale the default encoding is `none`, which raises `unknown encoding name - none`. Don't bring back the old `force_encoding('ISO-8859-1')` workaround (hotfixes 17.0.2/17.0.3). It garbled accented suggestions (`corazÃ³n`) or flagged correct accented words, depending on the environment. The accented-text tests in `test/speller_test.rb` cover both cases.

## Releases

Versions use `YY.minor.patch` (e.g. `17.0.4`) in `VERSION`. Hotfixes go on `hotfix/<name>` branches, bump `VERSION`, and add an entry to `CHANGELOG.md` (date plus a `**Fix**` line linking the PR). Changelog entries and older commits are often in Spanish.
