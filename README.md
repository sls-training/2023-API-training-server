# An API server

This API server is for learning what API is and how to create it.

## Setup

```sh
cp .env.sample .env

# And edit .env if necessary.

docker compose up -d db
docker compose run --rm app bin/setup
docker compose up -d
```
