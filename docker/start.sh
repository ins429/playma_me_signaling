#!/bin/bash

./_build/prod/rel/playma_me_signaling/bin/playma_me_signaling daemon
nginx -c /playmame_signaling/docker/nginx.conf

tail -f /playmame_signaling/nginx/access.log
