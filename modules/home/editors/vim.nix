{ inputs, ... }:
{
  flake.modules.homeManager.vim =
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
          unzip
          tree-sitter
        ];
      };

      xdg.configFile."nvim" = {
        # Keep config files centralized under ./configs/.
        source = inputs.self + /configs/nvim;
        recursive = true;
      };
    };
}
