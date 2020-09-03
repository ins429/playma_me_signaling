FROM erlang:22

WORKDIR /playma_me_signaling
COPY . .

# elixir expects utf8.
ENV ELIXIR_VERSION="v1.10.2" \
	LANG=C.UTF-8

RUN set -xe \
	&& ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/archive/${ELIXIR_VERSION}.tar.gz" \
	&& ELIXIR_DOWNLOAD_SHA256="5adffcf4389aa82fcfbc84324ebbfa095fc657a0e15b2b055fc05184f96b2d50" \
	&& curl -fSL -o elixir-src.tar.gz $ELIXIR_DOWNLOAD_URL \
	&& echo "$ELIXIR_DOWNLOAD_SHA256  elixir-src.tar.gz" | sha256sum -c - \
	&& mkdir -p /usr/local/src/elixir \
	&& tar -xzC /usr/local/src/elixir --strip-components=1 -f elixir-src.tar.gz \
	&& rm elixir-src.tar.gz \
	&& cd /usr/local/src/elixir \
	&& make install clean

RUN mix local.hex --force && \
    mix local.rebar --force && \
    wget https://github.com/phoenixframework/archives/raw/master/phx_new.ez && \
    mix archive.install --force ./phx_new.ez

RUN mix deps.get && \
    mix phx.digest && \
    MIX_ENV=prod mix release

EXPOSE 4000

ENV MIX_ENV=prod

CMD ["./_build/prod/rel/playma_me_signaling/bin/playma_me_signaling", "start"]
