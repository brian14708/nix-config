{ moduleWithSystem, ... }:
{
  flake.modules.homeManager.neovim = moduleWithSystem (
    { self', ... }:
    {
      config,
      lib,
      ...
    }:
    {
      options.my.neovim.package = lib.mkOption {
        type = lib.types.package;
        default = self'.packages.nvim;
        description = "Configured Neovim package to install.";
      };

      config.home = {
        packages = [ config.my.neovim.package ];
        sessionVariables = {
          EDITOR = "nvim";
          VISUAL = "nvim";
        };
      };
    }
  );

  perSystem =
    { pkgs, lib, ... }:
    {
      packages.nvim = lib.makeOverridable (
        {
          appName ? "nvim-nix",
          extraLuaConfig ? "",
        }:
        pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
          viAlias = true;
          vimAlias = true;
          withPython3 = false;
          withRuby = false;

          # Load the same configuration with nix run, Home Manager, and Neovide.
          luaRcContent = ''
            ${extraLuaConfig}
            vim.opt.rtp:prepend("${pkgs.vimPlugins.lazy-nvim}")
            dofile("${../../../configs/nvim}/init.lua")
          '';

          # Keep project tools first, with these available outside a development shell.
          wrapperArgs = [
            "--set"
            "NVIM_APPNAME"
            appName
            "--suffix"
            "PATH"
            ":"
            (lib.makeBinPath (
              with pkgs;
              [
                bat
                coreutils
                curl
                fd
                file
                fzf
                gcc
                git
                gnumake
                gnutar
                gzip
                nix
                nodejs
                openssh
                ripgrep
                tree-sitter
                unzip
                wget
              ]
              ++ lib.optionals stdenv.hostPlatform.isLinux [
                wl-clipboard
                xclip
                xdg-utils
              ]
            ))
          ];
        }
      ) { };
    };
}
