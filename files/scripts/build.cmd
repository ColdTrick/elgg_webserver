@echo off

echo Starting build
docker build -t coldtrick/elgg_webserver:latest --pull -q --no-cache .

echo.
echo Starting webserver
docker run --name webserver -d --rm coldtrick/elgg_webserver:latest

echo.
echo Using PHP version
docker exec -it webserver php -v

echo.
echo Stopping websever
docker stop webserver
