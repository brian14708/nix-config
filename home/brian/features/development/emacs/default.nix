{
  pkgs,
  ...
}:
{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
  };
  services.emacs = {
    enable = true;
    socketActivation.enable = true;
  };
  xdg.configFile."emacs/init.el".source = ./init.el;
  xdg.configFile."emacs/early-init.el".source = ./early-init.el;
}
