{ config, ... }:
let
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.homeManager."hosts/macbookpro" =
    { pkgs, config, ... }:
    {
      imports = with hm; [
        cli
        sops
      ];
      sops.secrets."hosts/macbookpro/ssh" = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519";
        mode = "0600";
      };
      home = {
        stateVersion = "24.11";
        packages = with pkgs; [
          colima
          docker-client
          nil
          nixfmt
          maple-mono.NF-CN
        ];
      };
      programs = {
        zsh.enable = true;
        neovide = {
          settings = {
            fork = true;
            font = {
              normal = [ "Maple Mono NF CN" ];
              size = 12;
            };
            theme = "dark";
            frame = "transparent";
          };
        };
        jujutsu = {
          settings = {
            ui.pager = ":builtin";
          };
        };
        ssh = {
          matchBlocks."github.com" = {
            hostname = "github.com";
            proxyCommand = "${pkgs.corkscrew}/bin/corkscrew 127.0.0.1 6152 %h %p";
          };
        };
      };
      xdg.configFile."ghostty/config".text = ''
        font-family = "Maple Mono NF CN"
        theme = "Catppuccin Mocha"
      '';
      targets.darwin.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;
      gtk.gtk4.theme = null;
    };

  flake.modules.darwin."hosts/macbookpro" = {
    imports = with config.flake.modules.darwin; [
      base
      locale-cn
      home-manager
      stylix
    ];
    networking.hostName = "macbookpro";
    system = {
      stateVersion = 5;
      keyboard.enableKeyMapping = true;
      keyboard.remapCapsLockToControl = true;
    };
    nix = {
      enable = false;
    };
    homebrew = {
      enable = true;
      user = "brian";
    };
    programs.zsh.shellInit = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';
    homebrew.casks = [
      "tailscale-app"
      "ghostty"
      "alfred"
      "surge"
      "1password"
      "obsidian"
    ];
    users.users.brian.home = "/Users/brian";
  };
}
