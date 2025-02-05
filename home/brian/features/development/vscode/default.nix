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
      mkhl.direnv
    ];

    userSettings = {
      "window.menuBarVisibility" = "toggle";
      "editor.semanticHighlighting.enabled" = true;
      "editor.minimap.enabled" = false;
      "terminal.integrated.profiles.linux" = {
        "bash" = {
          "path" = "${pkgs.bashInteractive}/bin/bash";
        };
      };

      "workbench.startupEditor" = "newUntitledFile";
      "workbench.activityBar.location" = "top";
      "vim.handleKeys" = {
        "<C-p>" = false;
        "<C-i>" = false;
      };
    };
  };
}
