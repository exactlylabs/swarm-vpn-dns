#!/usr/bin/env sh

if [[ -z "${NETWORK_NAME}" ]]; then
  echo Environment variable NETWORK_NAME must be set >&2
  exit 1
fi

if [ ! -e "/var/run/docker.sock" ]; then
  echo "You must give access to /var/run/docker.sock within this container"
  echo "e.g. via -v /var/run/docker.sock:/var/run/docker.sock"
  exit 1
fi

if [[ -z "${DOMAIN_NAME}" ]]; then
  export DOMAIN_NAME=internal
fi

if [[ -z "${REFRESH_INTERVAL}" ]]; then
  export REFRESH_INTERVAL=60
fi

# Modify default Dnsmasq config
sed -i 's/#no-hosts/no-hosts/g' /etc/dnsmasq.conf
echo "no-resolv" > /etc/dnsmasq.d/upstream.conf

/usr/sbin/dnsmasq --addn-hosts /etc/container_hosts

while true; do
  NETWORK_ID=$(curl -s --unix-socket /var/run/docker.sock  http://v1.47/networks | jq -r '.[] | select(.Name == "'$NETWORK_NAME'") | .Id')

  > /etc/container_hosts

  curl -s --unix-socket /var/run/docker.sock  http://v1.47/networks/$NETWORK_ID | jq -r '.Containers | to_entries[] | "\(.key) \(.value.Name) \(.value.IPv4Address)"' | while read CONTAINER_ID NAME IP_CIDR; do
    IP=$(echo "$IP_CIDR" | cut -d/ -f1)

    # Add standard domain
    echo "$NAME" | sed -E 's/^([^_.]+)_([^\.]+).*/'"$IP"' \2.\1.'$DOMAIN_NAME'/' >> /etc/container_hosts

    # Add extra domains from label
    EXTRA=$(curl -s --unix-socket /var/run/docker.sock http://v1.47/containers/$CONTAINER_ID/json | jq -r '.Config.Labels["swarm-vpn-dns.domains"] // ""')
    if [ -n "$EXTRA" ]; then
      for DOMAIN in $EXTRA; do
        echo "$IP $DOMAIN" >> /etc/container_hosts
      done
    fi
  done

  pkill -SIGHUP dnsmasq

  sleep $REFRESH_INTERVAL
done
