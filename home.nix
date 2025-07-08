{
  config,
  pkgs,
  inputs,
  system,
  ...
}: let
  importGpgScript = ./scripts/import-gpg.sh;
  gpgFingerprint = "984BED610B4D4D5554B00B5CE4ACD897C85DFDDE";
in {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "wojtek";
  home.homeDirectory = "/home/wojtek";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    pkgs.hello

    inputs.vim.packages.${system}.default

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  home.file.".bin/import-gpg-from-1password.sh" = {
    source = importGpgScript;
    executable = true;
  };

  programs.bash.enable = true;

  programs.bash.shellAliases = {
    gpg-import = ''
      ITEM_ID="e4wxgjn4phyvfextcfx7eb5ywy" \
      FINGERPRINT="${gpgFingerprint}" \
      bash ~/.bin/import-gpg-from-1password.sh
    '';
  };

  programs.git = {
    enable = true;
    userName = "Wojciech Kania";
    userEmail = "wojtek@kania.sh";

    signing = {
      key = gpgFingerprint;
      signByDefault = true;
    };

    extraConfig = {
      init.defaultBranch = "master";
      pull.rebase = true;
      push.autoSetupRemote = true;
      commit.gpgSign = true;
      user.signingKey = gpgFingerprint;
    };
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/wojtek/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.ghostty = {
    enable = true;
    installVimSyntax = true;
    settings = {
      theme = "Monokai Pro Octagon";
      font-size = 11;
    };
  };

  programs.firefox.enable = true;
  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;
    config = {
      modifier = "Mod4";
      keybindings = let
        cfg = config.wayland.windowManager.sway.config;
        modifier = cfg.modifier;

        switchWorkspaces = builtins.listToAttrs (builtins.genList (
            i: {
              name = "${modifier}+${toString (i + 1)}";
              value = "workspace number ${toString (i + 1)}";
            }
          )
          9);

        moveWorkspaces = builtins.listToAttrs (builtins.genList (
            i: {
              name = "${modifier}+Shift+${toString (i + 1)}";
              value = "move container to workspace number ${toString (i + 1)}; workspace number ${toString (i + 1)}";
            }
          )
          9);
      in
        switchWorkspaces
        // moveWorkspaces
        // {
          "${modifier}+Space" = "exec ${cfg.menu}";
          "${modifier}+Return" = "exec ghostty";
          "${modifier}+Shift+e" = "swaymsg exit";
          "${modifier}+B" = "exec firefox";
        };
    };
  };
}
