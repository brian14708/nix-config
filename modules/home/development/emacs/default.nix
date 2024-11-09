{
  pkgs,
  ...
}:
{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs30-pgtk;
  };
  services.emacs = {
    enable = true;
    socketActivation.enable = true;
  };
}
