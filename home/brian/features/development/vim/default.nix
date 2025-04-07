{
  pkgs,
  ...
}:
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    extraPackages = with pkgs; [
      gcc
      gnumake
      gopls
      gotools
      gofumpt
      nodejs
      ripgrep
      git
      wget
      fd
      unzip

      nil
      nixfmt-rfc-style
      lua-language-server
      basedpyright
    ];
  };

  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
  };
}
