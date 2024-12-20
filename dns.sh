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

/usr/sbin/dnsmasq --addn-hosts /etc/container_hosts

while true; do
  NETWORK_ID=$(curl -s --unix-socket /var/run/docker.sock  http://v1.47/networks | jq -r '.[] | select(.Name == "'$NETWORK_NAME'") | .Id')

  curl -s --unix-socket /var/run/docker.sock  http://v1.47/networks/$NETWORK_ID | jq -r '.Containers | .[] | "\(.Name) \(.IPv4Address)"' | sed -E 's/^([^_.]+)_([^\.]+).* ([0-9\.]+)\/([0-9]+)/\3 \2.\1.'$DOMAIN_NAME'/' > /etc/container_hosts

  pkill -SIGHUP dnsmasq

  sleep $REFRESH_INTERVAL
done
