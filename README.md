# ExDiet: calories calculator & daily meal planner

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
