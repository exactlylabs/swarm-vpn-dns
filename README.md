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

### To build locally

On first build, run `make prepare`
On all following builds run `make build`
