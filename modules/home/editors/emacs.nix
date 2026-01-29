{ inputs, ... }:
{
  flake.modules.homeManager.emacs =
    { pkgs, ... }:
    {
      programs.emacs = {
        enable = true;
        package = pkgs.emacs-pgtk;
      };

      services.emacs = {
        enable = true;
        socketActivation.enable = true;
      };

      xdg.configFile."emacs/init.el".source = inputs.self + /configs/emacs/init.el;
      xdg.configFile."emacs/early-init.el".source = inputs.self + /configs/emacs/early-init.el;
    };
}
