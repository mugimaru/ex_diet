# ExDiet: calories calculator & daily meal planner
[![build status](https://api.travis-ci.org/mugimaru73/ex_diet.svg?branch=master)](https://travis-ci.org/mugimaru73/ex_diet)

## Stack
* [Elixir](https://elixir-lang.org/)
* [Phoenix](http://phoenixframework.org/)
* [GraphQL](graphql.org) with [absinthe](https://github.com/absinthe-graphql/absinthe)
* [Vue.js](https://vuejs.org/)
* [TwitterBootstrap 4](https://getbootstrap.com/)

## TODO

### Backend
- [x] bootstrap a phoenix app
- [x] setup graphql endpoint
- [x] setup token authentication
- [x] build the core domain (ingredients, recipes, meals, calendar, etc)
- [x] build graphql API
- [x] deployment [gigalixir.com](https://gigalixir.com/)
- [ ] docs & test coverage
- [ ] fix SQL n+1 on recipe/calendar eatable attributes

### Frontend
- [x] bootstrap an UI with vuejs
- [x] implement authentication
- [x] add ingredients crud
- [x] add recipes
- [x] add calendar dashboard
- [ ] dashboard forms validation
- [ ] replace font-awesome with something that fits twbs better
- [ ] write tests
- [ ] improve UX

### Global
- [ ] Implement user profile (energy/macronutrients thresholds & body params)
- [ ] Find better way to serve static assets on production (proxy / -> /index.html)
- [ ] Consider having multiple profiles per account or connected accounts with shared recipes pool (several people, same fridge)
- [ ] I18n

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
# prepare backend
mix deps.get
mix ecto.prepare

# prepare frontend
cd assets && npm install && cd -

# start everything with foreman
gem install foreman
foremant start
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
