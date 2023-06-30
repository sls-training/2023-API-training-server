# An API server

This API server is for learning what API is and how to create it.

## Setup

```sh
docker compose up -d db
docker compose run --rm app bin/setup
docker compose up -d
```

### Optional

Install type signatures.

```sh
docker compose exec app bundle exec rbs collection install --frozen
```

Generate type signatures for this Rails application.

```sh
bin/rails rbs_rails:all
```

## Test

```sh
docker compose exec rubocop bin/rubocop
docker compose exec app bin/rspec
```
