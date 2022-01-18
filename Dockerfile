FROM elixir:1.13.0

RUN apt-get -y update && \
    apt-get install -y nginx

WORKDIR /playmame_signaling
COPY . .

RUN mix local.hex --force && \
    mix local.rebar --force && \
    wget https://github.com/phoenixframework/archives/raw/master/phx_new.ez && \
    mix archive.install --force ./phx_new.ez

RUN mix deps.get && \
    mix phx.digest && \
    MIX_ENV=prod mix release

EXPOSE 8080:443
EXPOSE 8081:80

ENV MIX_ENV=prod

WORKDIR /playmame_signaling

RUN mkdir -p /playmame_signaling/nginx && \
    touch /playmame_signaling/nginx/access.log && \
    touch /playmame_signaling/nginx/error.log;

CMD ["./docker/start.sh"]
