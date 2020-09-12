# ExDiet: calories calculator & daily meal planner

[![build status](https://api.travis-ci.org/mugimaru73/ex_diet.svg?branch=master)](https://travis-ci.org/mugimaru73/ex_diet)

There is a lot of great diet journals available on the internet (for example [myfitnesspal](https://www.myfitnesspal.com/)).
They provide you access to a community-driven database of meals and ingredients with the UX focused on logging what you've eaten with minimal efforts.
This works great with ready-to-eat products from popular brands or meals from chain restaurants but it doesn't work for home-made food. Different ingredients and proportions
used in your recipes lead to the significantly different nutritional value of your meal.

What my ideal diet planner looks like:

- It allows me to maintain a private database with ingredients from local markets;
- It allows me to calculate the nutritional value of meals that I cooked from those ingredients precisely;
- It allows me to fill in my diet journal using data from the above steps;
- It visualizes daily totals so I can match them with recommended thresholds;

With those use cases in mind, I created ex_diet. At this point, it provides all of the features mentioned above and I use it every day. You can try it out at [exdiet.tk](https://exdiet.tk) or fork it and refer to the deployment section to create your instance.

## Stack

- [Elixir](https://elixir-lang.org/)
- [Phoenix](http://phoenixframework.org/)
- [GraphQL](graphql.org) with [absinthe](https://github.com/absinthe-graphql/absinthe)
- [Vue.js](https://vuejs.org/)
- [TwitterBootstrap 4](https://getbootstrap.com/)

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

## Docker release

Docker release contains both frontend and backend parts of the project.
Backend application provides an API and serves static assets.

Build an image:

        make build-image

Run the image:

        docker run --env-file .env ex_diet:0.2.0

Run the latest published image:

        docker run --env-file .env docker.pkg.github.com/mugimaru73/ex_diet/ex_diet:latest

Use `.services.release.environment` from `.docker-compose.yml` as a reference to compose .env file.
