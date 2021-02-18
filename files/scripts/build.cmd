@echo off

SET logdir=%~dp0

echo Starting build
docker build -t coldtrick/elgg_webserver:latest --pull -q .

echo.
echo Starting webserver
docker run --name webserver -d --rm coldtrick/elgg_webserver:latest

echo.
echo Using PHP version
docker exec -it webserver php -v

echo.
echo Stopping websever
docker stop webserver
