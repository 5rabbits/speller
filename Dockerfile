# Development image for the speller service.
# Keep the Ruby version in sync with .ruby-version (the Gemfile enforces it).
FROM docker.io/library/ruby:4.0.9-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      build-essential \
      git \
      libaspell-dev \
      aspell-en \
      aspell-es \
      aspell-pt-br \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock .ruby-version ./
RUN bundle install

COPY . .

EXPOSE 3019

# rerun restarts the server on source changes. Polling is required: file events
# from the host do not reach the container through the podman machine mount.
CMD ["bundle", "exec", "rerun", "--background", "--force-polling", "--", \
     "rackup", "--host", "0.0.0.0", "--port", "3019"]
