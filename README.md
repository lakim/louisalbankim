Install
-------

On your local machine:

```shell
vagrant plugin install vagrant-vbguest
vagrant up
vagrant reload # System restart required after kernel update
vagrant ssh
```

On the VM:

```shell
cd /vagrant
docker build -t louisalbankim ./docker
docker run -p 80:80 -p 2222:22 \
  -v /home/deploy:/home/deploy \
  -v /vagrant:/vagrant \
  -e RACK_ENV=development \
  louisalbankim
```

Deploy user
-----------

The deploy user shares the same id on the host and the container. This is necessary to allow Passenger to right files (cache, log, etc.).
The /home/deploy directory is also shared between host and container.

SSH
---

The container has port 22 bound to port 2222 on the host to allow you to SSH directly from your machine.

```shell
# Copy your public key to the deploy user
ssh vagrant@33.33.33.10 -i ~/.ssh/vagrant 'cat | sudo -u deploy tee /home/deploy/.ssh/authorized_keys' < ~/.ssh/id_rsa.pub
# SSH directly to the container as deploy user
ssh -p 2222 deploy@33.33.33.10
```

Production
----------

```shell
# Provision the server
ssh root@louisalbankim.com 'bash -s' < ./docker/host.sh
# Copy your public key to the deploy user
ssh root@louisalbankim.com 'cat | sudo -u deploy tee /home/deploy/.ssh/authorized_keys' < ~/.ssh/id_rsa.pub
# Capistrano
```

```shell
ssh root@louisalbankim.com
cd /home/deploy/current
docker build -t louisalbankim ./docker
docker run -d -p 80:80 -p 2222:22 \
  -v /home/deploy:/home/deploy \
  -e RACK_ENV=production \
  louisalbankim
```

TODO
----

* content helper: content(slug) => OK
* specify layout per type => OK
* view per type => OK
* posts#index => OK
* tags#show => OK
* tags helper => OK
* tags identity map => OK
* page caching => OK
* manage drafts (*) => OK
* sitemap => OK
* move page cache to public/cache => OK
* code highlight
* links should be target=_blank
* pagination
* RSS feed
* config file (twitter account, GA id, ...)

* extract engine
* tests tests tests
** names : devcms, hackercms

Design inspiration
------------------

http://weareimpero.com/
http://thisisyoke.com/

Articles
--------

* bundle install -j 4
* list capybara methods that wait

TODO
----

* host and container share a data volume (docker run -v ...) => OK
* configure vagrant shared folder as deploy user => OK
* persist deploy folder on host => OK
* in prod, deploy with capistrano to container (or host?)
* verify http headers in production for cached pages
* use minimal image
* Firewall
* Remove passenger log messages
* Google Analytics
