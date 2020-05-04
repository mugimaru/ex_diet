# ExDiet: calories calculator & daily meal planner
[![build status](https://api.travis-ci.org/mugimaru73/ex_diet.svg?branch=master)](https://travis-ci.org/mugimaru73/ex_diet)

## Stack
* [Elixir](https://elixir-lang.org/)
* [Phoenix](http://phoenixframework.org/)
* [GraphQL](graphql.org) with [absinthe](https://github.com/absinthe-graphql/absinthe)
* [Vue.js](https://vuejs.org/)
* [TwitterBootstrap 4](https://getbootstrap.com/)

## Development

With docker and docker-compose installed.

build images

    make compose-build

run application

    make compose-up

run backend tests

    make compose-be-make-test

run bash inside backend container

    make compose-be-run-bash

run bash inside frontend container

    make compose-fe-run-bash
