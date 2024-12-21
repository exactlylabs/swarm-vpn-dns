# Swarm DNS

This container is intended to be used with a VPN connected to a specific Swarm network.
It will provide name resolution for containers within that network to simplify access for
administrative tasks. It is also intended to be used with a split DNS style setup where
this container is responsibile for a specific domain name where other names on the network
are resolved by another DNS setup.

Under the covers this runs Dnsmasq.

Example running:

```
docker run -it -v /var/run/docker.sock:/var/run/docker.sock -e NETWORK_NAME=vpn exactlylabs/swarm-vpn-dns
```

Or in compose for swarm:

```
services:
  vpn-dns:
    image: exactlylabs/swarm-vpn-dns:0.0.1
    networks:
      - vpn
    environment:
      - NETWORK_NAME=vpn
      - DOMAIN_NAME=my.domain.internal
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock

networks:
  vpn:
    external: true
```

### Environment Variables

* NETWORK_NAME: Name of the docker network to resolve dns for. This field is required.
* DOMAIN_NAME: Name to suffix containers with -- default is 'internal'
* REFRESH_INTERVAL: Poll interval for refreshing domain names -- default is 60 if unset.

### Example running on swarm with Tailscale VPN

Create a network called `vpn` using the command -- replace the subnet with subnet of your choosing. It must be different than anything else on your tailnet. A few prerequisites -- your swarm host must be on your tailnet with a known IP address and you must be able to expose a DNS server on port 53 with udp / tcp on this machine safely / not on the open internet. You must also be ok with the DNS server container having access to Docker / Swarm APIs -- this is needed to discover the IPs that have been issused to the containers within the specified network.

```
docker network create --driver overlay --subnet=192.168.52.0/24 --attachable vpn
```

Create the following `docker-compose.yml` file:

```
services:
  tailscale:
    image: tailscale/tailscale:latest
    hostname: tailscale
    environment:
      - TS_HOSTNAME=tailscale-swarm
      - TS_AUTHKEY=tskey-auth-replace-with-one-time-use-key # One time use key, needs to be regenerated
      - TS_STATE_DIR=/var/lib/tailscale
      - TS_USERSPACE=false
      - TS_ROUTES=192.168.52.0/24 # same subnet as above
      - TS_EXTRA_ARGS=--accept-routes
    volumes:
      - /local/path/here/to/save/auth/info:/var/lib/tailscale
    devices:
      - /dev/net/tun:/dev/net/tun
    cap_add:
      - net_admin
      - sys_module
    networks:
      - vpn
  dns:
    image: exactlylabs/swarm-vpn-dns:0.0.1
    ports:
      - 53:53/udp
      - 53:53
    environment:
      - NETWORK_NAME=vpn
      - DOMAIN_NAME=your.own.dns.internal # replace with your domain name
    networks:
      - vpn
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock

networks:
  vpn:
    external: true
```

Deply the this as a new stack:

```
docker stack deploy -c ./docker-compose.yml vpn
```

Then on any other stack / container -- ensure it is added to the `vpn` network to be sure it
is accessable.

In Tailscale admin, go to "DNS" and add a custom nameserver where the ip is the swarm host ip and you've selected "Restrict to domain" and set the domain to the same value as `DOMAIN_NAME`. Also be sure to accept the advertised routes from the admin UI for the routes in your swarm network.

### To build locally

On first build, run `make prepare`
On all following builds run `make build`
