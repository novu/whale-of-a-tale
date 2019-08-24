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

Go to [http://localhost:3000/] in your favorite browser.
Click the sky to make the whale fly! Watch your logs to see ActionCable and Sidekiq working to send the message around.

## Thanks to...
[https://github.com/nickjj/orats] - Template that this repo is based off of
[https://evilmartians.com/chronicles/evil-front-part-1] - Evil Martians' guide to front end Rails from 2017
