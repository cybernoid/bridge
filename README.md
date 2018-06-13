# bridge docker container

*brigde* is a dynamic port forwarder over HTTP (with HTTP PROXY support). For
more information on how this works see the [original
project](https://github.com/luizluca/bridge) on github.

This fork adds the necessary stuff to build a docker image for it. The
application is not modified in any way. The docker container supports the
client side as well as the server side, since thankfully both differ only in
the parameters passed to the application.

## Server side

Since *bridge* is a tunnel through http, it is also possible to run the server
side as a virtual host in the context of a reverse proxy, e.g. Jason Wilder's
[nginx-proxy](https://hub.docker.com/r/jwilder/nginx-proxy/). This allows using
a computer as tunnel endpoint that is also serving web pages on port 80. The
*bridge* application has no inbuilt support for SSL, so to get a secure
connection you basically have two choices:

1. tunnel an otherwise secure protocol like ssh or
2. use the aforementioned nginx-proxy to handle the SSL part and let it talk
   non-encrypted http with *bridge* running inside the container. See the
   nginx-proxy documentation on how to do this (hint: environment HTTPS\_METHOD).

A very basic *docker-compose.yml* file for running the server side as standalone
service on *http://yourhost.yourdomain.tld:80/bridge* looks like this:

```
version: '2'

services:
    http-bridge:
        image: http-bridge
        ports:
            - "80:80"
```

If for some reason you want to change the port or directory the server listens
to internally, add sth. like the following to the service's section:

```
       command: 8080 /bridge # first is the server port, second the directory
       expose:
           - "8080"          # by default, only port 80 is exposed
       ports:
           - "8080:8080"
```

A *docker-compose.yml* file for use with the nginx-proxy might look like this:

```
version: '2'

services:
    http-bridge:
        image: http-bridge
        network_mode: "bridge" # I put the nginx-proxy and it's backends on this network
        environment:
            - HTTPS_METHOD=noredirect
            - VIRTUAL_HOST=yourvirtualhost.yourdomain.tld
```

## Client side

The main use case of bridge is tunneling ssh out, so here is a sample *~.ssh/config*
file for your client behind the firewall that uses the *bridge* container:

```
host yourhost
    HostName yourvirtualhost.yourdomain.tld
    ProxyCommand docker run -i http-bridge - http://%h/bridge %h 22
```

Now call ssh as usual:

```
client$ ssh yourhost
Password:

yourhost $
```
