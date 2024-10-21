{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    plugins =
      with pkgs.vimPlugins;
      [
      ];
    extraPackages = with pkgs; [
      gcc
      nil
      nixfmt-rfc-style
      lua-language-server
    ];
  };

  xdg.configFile."nvim" = {
    source = ./nvchad;
    recursive = true;
  };
}
