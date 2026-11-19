---
name: nixos-module-conventions
description: How a NixOS service module is built in this repo. Use when adding, changing, or reviewing a module under modules/nixos/services/.
---

# NixOS service modules

This repo ships service definitions that the private flake consumes as a plain source tree (`flake = false`, pinned by commit). Host wiring, secrets, and deployment live in `homelab-gitops-private`.

## Shape

- One directory per service: `modules/nixos/services/<service>/default.nix` plus the `<service>.container` Quadlet.
- Export it from the `imports` list in `modules/nixos/services/default.nix`.
- The Quadlet is a template. Placeholders like `@LISTEN_ADDRESS@` are replaced with `builtins.replaceStrings` from the module's options, then written to `environment.etc."containers/systemd/<service>.container".text`.
- Options live under `homelab.services.<service>`: `enable = lib.mkEnableOption "..."`, and typed `lib.mkOption` values with a default and a description. Guard config with `lib.mkIf cfg.enable`.

## What belongs here

- The service definition, its Quadlet, and its static config files.
- Public app selection in the aggregator: `homelab.services.<name>.enable = true`.
- The ports the app listens on and its `homelab.persistence.paths` entries. Let the app/systemd manage state directories; don't guess ownership with tmpfiles rules.

## What does not

- Per-host bind addresses beyond a `listenAddress` option with a loopback default.
- Secrets and secret references. The private repo resolves them.
- Restic enablement, backup schedules, or host names.

## Images

- Pin the image tag in the `.container` file. A floating tag is a change nobody reviewed.

## Validation

- There is no flake here, so nothing validates locally. The module is evaluated by the private flake's `checks`; a bad option or an unreplaced placeholder surfaces there.
