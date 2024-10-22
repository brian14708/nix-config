{ pkgs, ... }:
{
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

      nil
      nixfmt-rfc-style
      lua-language-server
    ];
  };

  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
  };
}
