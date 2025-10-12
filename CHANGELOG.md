# Changelog

All notable changes to this project will be documented in this file.

## [0.0.3] - 2025-10-11

### Added
- Support for additional domain mappings via the `swarm-vpn-dns.domains` container label

## [0.0.1] - Initial Release

### Added
- Basic DNS resolution for Docker Swarm containers
- Auto-generates domain names as `<container-name>.<stack-name>.<DOMAIN_NAME>`
- Configurable network name, domain name, and refresh interval
- Dnsmasq-based DNS server
- Support for split DNS configurations
