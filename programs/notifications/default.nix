{pkgs, ...}: {
  home.packages = [pkgs.libnotify];

  services.mako = {
    enable = true;
    settings = {
      font = "TX-02 SemiCondensed 11";
      anchor = "top-right";
      width = 360;
      margin = "10";
      padding = "10,14";
      border-size = 1;
      border-radius = 8;
      background-color = "#1f1d2e";
      text-color = "#e0def4";
      border-color = "#403d52";
      progress-color = "over #26233a";
      default-timeout = 5000;
      max-visible = 5;
      group-by = "app-name";
      "urgency=low" = {
        text-color = "#908caa";
      };
      "urgency=critical" = {
        border-color = "#eb6f92";
        default-timeout = 0;
      };
      "mode=dnd" = {
        invisible = 1;
      };
    };
  };

  wayland.windowManager.sway.config.keybindings = {
    "Mod4+N" = "exec makoctl dismiss";
    "Mod4+Shift+N" = "exec makoctl dismiss --all";
    "Mod4+Control+N" = "exec makoctl restore";
    "Mod4+Alt+N" = "exec makoctl mode -t dnd";
  };
}
