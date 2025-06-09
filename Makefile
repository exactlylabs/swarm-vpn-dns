VERSION := 0.0.1

prepare:
	docker buildx create --name swarm-vpn-dns --use --bootstrap

build:
	docker buildx build --platform linux/amd64,linux/arm64 \
	  --tag exactlylabs/swarm-vpn-dns:$(VERSION) \
	  --tag exactlylabs/swarm-vpn-dns:latest

push:
	docker buildx build --platform linux/amd64,linux/arm64 \
	  --tag exactlylabs/swarm-vpn-dns:$(VERSION) \
	  --tag exactlylabs/swarm-vpn-dns:latest \
	  --push .
