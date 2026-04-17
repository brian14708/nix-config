# Repository Guidelines

Declarative Nix flake for personal machines, homelab, and lab cloud infrastructure.

## Quick Commands

- `nix develop`: enter the dev shell.
- `nix fmt`: run treefmt formatters (`nixfmt`, `stylua`, `prettier`, OpenTofu formatter).
- `nix flake check`: run CI-equivalent checks and fail if generated files are stale.
- `nix run .#write-flake`: regenerate the generated `flake.nix`.
- `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`: build a NixOS host.
- `nix build .#darwinConfigurations.<host>.system`: build a nix-darwin host.
- `just nix`: switch the current machine via `nh`.
- `just lab`: initialize and apply `infra/lab` with SOPS-injected secrets.
- `just cache [host]`: push a host closure to the binary cache.
- `just update`: update `flake.lock`, in-tree package pins, and regenerate `flake.nix`.

## Repository Map

- `flake.nix` / `flake.lock`: flake entry and lockfile. `flake.nix` is generated.
- `modules/flake/`: flake-file / flake-parts wiring, inputs, overlays, host builders, devshell, formatting, and template exports.
- `modules/hosts/<hostname>.nix`: host entrypoints. A host file typically defines `flake.modules.nixos."hosts/<hostname>"` and may also define `flake.modules.homeManager."hosts/<hostname>"`.
- `modules/nixos/`, `modules/home/`, `modules/darwin/`: reusable NixOS, home-manager, and nix-darwin modules.
- `pkgs/by-name/<name>/package.nix`: in-tree packages discovered through `pkgs/default.nix`.
- `configs/`: shared application config, patches, and encrypted secrets.
- `infra/lab/`: OpenTofu code and encrypted lab secrets.
- `templates/`: exported flake templates.
- `.sops.yaml`: SOPS recipients and creation rules for encrypted files.

## Working Rules

- This repo uses `flake-file`, `flake-parts`, and `import-tree`; module discovery is automatic, so new files under `modules/` can change outputs without editing `flake.nix`.
- Never hand-edit `flake.nix`. Change `modules/**/*.nix` and regenerate with `nix run .#write-flake`.
- Put reusable logic in `modules/nixos/**`, `modules/home/**`, or `modules/darwin/**`. Keep `modules/hosts/*.nix` focused on composition and host-specific settings.
- Add new flake behavior in a focused file under `modules/flake/` rather than extending an unrelated module.
- `modules/flake/hosts.nix` auto-registers NixOS hosts from `flake.modules.nixos."hosts/*"`.
- `modules/flake/home-manager.nix` attaches the matching `flake.modules.homeManager."hosts/<hostname>"` module using `networking.hostName`.
- Keep package updates in `pkgs/by-name/<name>/package.nix` unless the overlay machinery itself is changing.
- Secret material belongs in SOPS-managed files such as `configs/secrets.yaml` or `infra/lab/env.secrets.yaml`; update `.sops.yaml` when adding a new encrypted file or host key.
- Formatting is managed by treefmt. Lua uses `stylua` with 2-space indentation.

## Validation

- Run `nix fmt` after touching formatted sources.
- Run `nix run .#write-flake` after editing `modules/flake/**` or any change that should affect generated flake outputs.
- Run `nix flake check` for flake, shared module, package, or template changes.
- Build each affected host output for host-specific changes.
- For infrastructure changes, run `just lab` or at minimum `sops exec-env infra/lab/env.secrets.yaml 'cd infra/lab && tofu plan'`.
