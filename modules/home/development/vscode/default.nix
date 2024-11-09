{
  pkgs,
  ...
}:
{
  programs.vscode = {
    enable = true;
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;

    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      github.copilot
      github.copilot-chat
      bbenoist.nix
    ];

    userSettings = {
      "window.menuBarVisibility" = "toggle";
      "editor.semanticHighlighting.enabled" = true;
      "workbench.startupEditor" = "newUntitledFile";
      "workbench.activityBar.location" = "top";
      "vim.handleKeys" = {
        "<C-p>" = false;
        "<C-i>" = false;
      };
    };
  };
}
