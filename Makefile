VERSION := 0.0.1

prepare:
	docker buildx create --name swarm-vpn-dns --use --bootstrap

build:
	docker buildx build --load --platform linux/amd64 --tag exactlylabs/swarm-vpn-dns:$(VERSION) .
	docker tag exactlylabs/swarm-vpn-dns:$(VERSION) exactlylabs/swarm-vpn-dns:latest

push: build
	docker push exactlylabs/swarm-vpn-dns:$(VERSION)
	docker push exactlylabs/swarm-vpn-dns:latest
