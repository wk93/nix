{pkgs, ...}: {
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
    config.sway.default = ["wlr" "gtk"];
  };

  security.pam.services.swaylock = {};

  programs.dconf.enable = true;
}
