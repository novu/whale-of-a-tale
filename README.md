# whale-of-a-tale
[Skip to Rails and Docker content](#welcome).

[![](img/hiring_ad.jpg)](http://novu.com/join-us)

# Welcome!
Novu is a Ruby/Rails shop that has adopted Docker for both development and production. We learned a lot along the way and would like to share a basic, working example with the community.

Part of what's coolest about working with Docker is that your configuration can be baked in so well that new developers need to do very little to have a working copy of an application. This example shows that you can have multiple processes started from one image, all working together to make whales fly.

# Getting started
Make sure you have the [Docker Engine installed](https://hub.docker.com/editions/community/docker-ce-desktop-mac), if you have not already. Note that you'll need to sign up for an account. You can learn more about [Docker Engine](https://docs.docker.com/install/) here.

Clone this repo. Then run the following in your shell:
```
docker-compose build
docker-compose run --rm web rake db:create db:migrate
docker-compose up
```

Go to [http://localhost:3000/](http://localhost:3000/) in your favorite browser.
Click the sky to make the whale fly! Watch your logs to see ActionCable and Sidekiq working to send the message around.

## Thanks to...
[https://github.com/nickjj/orats](https://github.com/nickjj/orats) - Opinionated Rails Template that this repo is based off of
[https://evilmartians.com/chronicles/evil-front-part-1](https://evilmartians.com/chronicles/evil-front-part-1) - Evil Martians' guide to front end Rails and Webpacker
