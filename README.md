# ExDiet: calories calculator & daily meal planner
[![build status](https://api.travis-ci.org/mugimaru73/ex_diet.svg?branch=master)](https://travis-ci.org/mugimaru73/ex_diet)

## Stack
* [Elixir](https://elixir-lang.org/)
* [Phoenix](http://phoenixframework.org/)
* [GraphQL](graphql.org) with [absinthe](https://github.com/absinthe-graphql/absinthe)
* [Vue.js](https://vuejs.org/)
* [TwitterBootstrap 4](https://getbootstrap.com/)

## TODO
- [x] bootstrap a phoenix app
- [x] bootstrap an UI with vuejs
- [x] setup graphql endpoint
- [x] setup token authentication
- [ ] build the core domain (ingredients, recipes, meals, calendar, etc)
- [ ] build graphql API
- [ ] add an UI


## Development

### Docker

prepare an image
```
docker-compose build web
docker-compose run web mix ecto.prepare
```

```
docker-compose up web
```

### Localhost

```
mix deps.get
mix ecto.prepare
mix phx.server
```

### Graphql tools

Update schema.graphql
```
npm install -g get-graphql-schema
get-graphql-schema http://localhost:4000/api/graphql > schema.graphql
```

Run graphql playground
```
npm install -g graphql-cli
graphql playground
```

## Test

### Docker

```
docker-compose run --rm test
```

### Localhost

```
mix deps.get
mix test
```
