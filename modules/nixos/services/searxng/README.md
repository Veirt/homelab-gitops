# SearXNG NixOS module

This module provides the shared SearXNG configuration and root-managed Podman
Quadlet. Import `nixosModules.searxng` from this flake, then enable
`homelab.services.searxng` and set its LAN `listenAddress` in the private host
configuration. The module publishes port `18888` and expects the host to provide
`/var/lib/searxng/searxng.env` with mode `0600`; secret values do not belong in
this repository or the Nix store.

Host-specific firewall rules, state directory permissions, backup paths, reverse
proxy and DNS records remain in the private host and infrastructure repositories.
The Kubernetes manifests in `apps/searxng` are retained until the Iris cutover's
backup and runtime checks are complete.
