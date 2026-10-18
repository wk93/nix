{pkgs, ...}: let
  gtkCss = ''
    @define-color accent_color #ebbcba;
    @define-color accent_bg_color #ebbcba;
    @define-color accent_fg_color #191724;
    @define-color destructive_color #eb6f92;
    @define-color destructive_bg_color #eb6f92;
    @define-color destructive_fg_color #191724;
    @define-color success_color #9ccfd8;
    @define-color success_bg_color #31748f;
    @define-color success_fg_color #e0def4;
    @define-color warning_color #f6c177;
    @define-color warning_bg_color #f6c177;
    @define-color warning_fg_color #191724;
    @define-color error_color #eb6f92;
    @define-color error_bg_color #eb6f92;
    @define-color error_fg_color #191724;
    @define-color window_bg_color #191724;
    @define-color window_fg_color #e0def4;
    @define-color view_bg_color #1f1d2e;
    @define-color view_fg_color #e0def4;
    @define-color headerbar_bg_color #1f1d2e;
    @define-color headerbar_fg_color #e0def4;
    @define-color headerbar_border_color #26233a;
    @define-color headerbar_backdrop_color #191724;
    @define-color headerbar_shade_color rgba(0, 0, 0, 0.36);
    @define-color card_bg_color #1f1d2e;
    @define-color card_fg_color #e0def4;
    @define-color card_shade_color rgba(0, 0, 0, 0.36);
    @define-color dialog_bg_color #1f1d2e;
    @define-color dialog_fg_color #e0def4;
    @define-color popover_bg_color #1f1d2e;
    @define-color popover_fg_color #e0def4;
    @define-color sidebar_bg_color #1f1d2e;
    @define-color sidebar_fg_color #e0def4;
    @define-color sidebar_backdrop_color #191724;
    @define-color sidebar_shade_color rgba(0, 0, 0, 0.36);
    @define-color thumbnail_bg_color #26233a;
    @define-color thumbnail_fg_color #e0def4;
    @define-color shade_color rgba(0, 0, 0, 0.36);
    @define-color scrollbar_outline_color rgba(0, 0, 0, 0.5);
  '';
in {
  home.packages = [pkgs.xarchiver];

  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "rose-pine";
      package = pkgs.rose-pine-icon-theme;
    };
    gtk3.extraCss = gtkCss;
    gtk4 = {
      theme = null;
      extraCss = gtkCss;
    };
  };

  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
    flavors.rose-pine = pkgs.fetchFromGitHub {
      owner = "Mintass";
      repo = "rose-pine.yazi";
      rev = "d91f8f2ef53b5ba4edb455164b1570f9c3a8341a";
      hash = "sha256-+7viMu6pCL49avTGUDufobpqg149PLkLiLvWAGJSgIM=";
    };
    theme.flavor = {
      dark = "rose-pine";
      light = "rose-pine";
    };
    settings.mgr = {
      ratio = [1 3 4];
      sort_by = "natural";
      sort_dir_first = true;
    };
  };

  # Lets yazi show image previews through tmux
  programs.tmux.extraConfig = ''
    set -g allow-passthrough on
    set -ga update-environment TERM
    set -ga update-environment TERM_PROGRAM
  '';

  wayland.windowManager.sway.config.keybindings = {
    "Mod4+E" = "exec ghostty -e yazi";
    "Mod4+T" = "exec thunar";
  };
}
