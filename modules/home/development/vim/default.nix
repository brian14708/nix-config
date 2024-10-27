{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.programs.neovim.lua.theme = lib.mkOption {
    type = lib.types.str;
    default = ''
      return {
        'folke/tokyonight.nvim',
        priority = 1000,
        opts = {
          transparent = true,
        },
        init = function()
          vim.cmd.colorscheme 'tokyonight-night'
        end,
      };
    '';
  };
  config = {
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;
      extraPackages = with pkgs; [
        gcc
        gnumake
        nodejs
        ripgrep
        git
        wget
        fd
        wl-clipboard

        nixd
        nixfmt-rfc-style
        lua-language-server
      ];
    };

    xdg.configFile."nvim" = {
      source = ./nvim;
      recursive = true;
    };

    xdg.configFile."nvim/lua/theme.lua" = {
      text = config.programs.neovim.lua.theme;
    };
  };
}
