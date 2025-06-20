{
  pkgs,
  ...
}:
{
  programs.neovide = {
    enable = true;
    settings = {
    };
  };
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
      unzip

      nil
      gopls
      gofumpt
      gotools
      rust-analyzer
    ];
  };

  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
  };
}
