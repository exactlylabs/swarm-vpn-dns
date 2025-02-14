FROM alpine:3.21.0

RUN apk add --no-cache dnsmasq curl jq

COPY dns.sh /

EXPOSE 53 53/udp

CMD [ "/dns.sh" ]
