@echo off

echo Starting webserver
docker run --name webserver -d --rm coldtrick/elgg_webserver:latest
