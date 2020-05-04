FROM elixir:1.10

RUN mkdir -p /home/user && chmod 777 /home/user
ENV HOME /home/user
RUN mix local.hex --force && mix local.rebar --force

