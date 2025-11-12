@echo off

echo Starting webserver
docker run --name webserver -d --rm -v .:/var/www/cacheroot coldtrick/elgg_webserver:latest
