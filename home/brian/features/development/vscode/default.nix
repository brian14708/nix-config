{
  pkgs,
  config,
  ...
}:
let
  pname = config.programs.vscode.package.pname;
in
{
  programs.vscode = {
    enable = true;

    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;

      extensions =
        with pkgs.vscode-extensions;
        [
          vscodevim.vim
          mkhl.direnv
        ]
        ++ (
          if pname == "cursor" then
            [ ]
          else
            [
              github.copilot
              github.copilot-chat
            ]
        );

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
  };
}
