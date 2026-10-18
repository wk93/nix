{pkgs, ...}: {
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
    config.sway.default = ["wlr" "gtk"];
  };

  security.pam.services.swaylock = {};

  programs.dconf.enable = true;

  programs.thunar = {
    enable = true;
    plugins = [pkgs.thunar-volman pkgs.thunar-archive-plugin];
  };
  programs.xfconf.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;
}
