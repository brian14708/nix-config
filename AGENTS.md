# Repository Guidelines

Declarative, reproducible Nix flake for my personal desktops/laptops and homelab, including cloud infrastructure.

## Quick Commands

- Enter devshell: `nix develop`
- Format (treefmt): `nix fmt`
- CI checks: `nix flake check`
- Build a NixOS host: `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`
- Build a nix-darwin host: `nix build .#darwinConfigurations.<host>.system`
- Switch the current system: `just nix` (via `nh`)
- Lab infra: `just lab` (runs OpenTofu with secrets via `sops exec-env`)
- Update `flake.lock` + in-tree packages: `just update`

## Project Structure & Module Organization

- `flake.nix` / `flake.lock`: flake entrypoint (`flake.nix` is generated; see below).
- `modules/`: flake-parts modules (auto-imported via `import-tree`).
- `modules/flake/`: flake wiring (inputs, overlays, devshell, formatting, host builders, templates export).
- `modules/nixos/`: reusable NixOS modules (`hardware/`, `networking/`, `profiles/`, `services/`, ...).
- `modules/home/`: reusable Home Manager modules (`base/`, `profiles/`, `programs/`, `editors/`, `wayland/`, ...).
- `modules/darwin/`: reusable nix-darwin modules.
- `modules/hosts/<hostname>.nix`: per-machine modules (usually defines `flake.modules.nixos."hosts/<name>"` and optionally `flake.modules.homeManager."hosts/<name>"`).
- `pkgs/`: local overlay + in-tree packages + patches (examples: `pkgs/default.nix`, `pkgs/tailscale.patch`).
- `pkgs/by-name/<name>/package.nix`: in-tree packages (flake packages: `nix build .#<name>`).
- `infra/lab/`: OpenTofu (Terraform) for lab infrastructure (secrets via `sops exec-env` on `infra/lab/env.secrets.yaml`).
- `configs/`: shared config files plus SOPS-encrypted secrets (`configs/secrets.yaml`).
- `templates/`: flake templates (see `templates/default.nix`).

## Conventions

- Prefer `modules/nixos/**`, `modules/home/**`, and `modules/darwin/**` for reusable modules.
- Prefer `modules/hosts/<hostname>.nix` for host-specific changes.
- Prefer `pkgs/by-name/<name>/package.nix` for package updates.

## Version Control (jj) / PRs

- Use Jujutsu (`jj`) as the VCS UI (git-compatible repo for GitHub/CI).
- Describe changes before pushing (the message becomes the git commit message): `jj describe -m "..."`.
- Common commands: `jj status`, `jj diff`, `jj log`, `jj git fetch`, `jj git push`.
- PRs should include: a short rationale, what hosts/modules are affected, and commands you ran (usually `nix fmt` and `nix flake check`).

## Security & Configuration Tips

- Do not commit decrypted secrets. Edit secrets with `sops`.
- SOPS config lives in `.sops.yaml`.

## Dendritic Pattern (Nix)

- Configuration is organized as aspects: modules contribute to `flake.modules.<class>.<aspect>` (example: `modules/flake/secret.nix` defines the `sops` aspect for `nixos` and `homeManager`).
- `flake.nix` is generated via flake-file's dendritic module (see `modules/flake/dendritic.nix`); modules are loaded via `import-tree`.
- Add new flake-parts modules by creating `.nix` files under `modules/`.
- Do not hand-edit `flake.nix`; change `modules/**/*.nix` and regenerate with `nix run .#write-flake`.
- `nix flake check` will fail if the generated `flake.nix` is stale.
