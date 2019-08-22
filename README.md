# whale-of-a-tale
Learn about doing Rails development with Docker from Novu’s perspective

# Getting started
Make sure you have Docker installed.
https://docs.docker.com/install/
https://hub.docker.com/editions/community/docker-ce-desktop-mac

Clone this repo. Then run the following in your shell:
```
docker-compose build
docker-compose run --rm web rails db:create db:migrate
docker-compose up
```
