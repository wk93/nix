{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}: let
  importGpgScript = ./scripts/import-gpg.sh;
  importSshScript = ./scripts/import-ssh.sh;
  gpgFingerprint = "984BED610B4D4D5554B00B5CE4ACD897C85DFDDE";
in {
  imports = [
    ./fonts.nix
  ];
  home.username = "wojtek";
  home.homeDirectory = "/home/wojtek";

  home.packages = with pkgs; [
    wl-clipboard
    git-crypt
    inputs.vim.packages.${system}.default
  ];

  home.file.".bin/import-gpg-from-1password.sh" = {
    source = importGpgScript;
    executable = true;
  };

  home.file.".bin/import-ssh-from-1password.sh" = {
    source = importSshScript;
    executable = true;
  };

  programs.zsh = {
    enable = true;

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      if [ -z "$TMUX" ] && [ -n "$DISPLAY" ] && [ "$TERM_PROGRAM" != "vscode" ]; then
        tmux attach-session -t default || tmux new-session -s default
      fi
    '';

    shellAliases = {
      gpg-import = ''
        ITEM_ID="e4wxgjn4phyvfextcfx7eb5ywy" \
        FINGERPRINT="${gpgFingerprint}" \
        bash ~/.bin/import-gpg-from-1password.sh
      '';
      ssh-import = ''
        SSH_DIR="$HOME/.ssh/keys" \
        KEYS="op://Private/GitHub Sign key/private key?ssh-format=openssh:::git_sign
              op://Private/Github Auth key/private key?ssh-format=openssh:::git_auth" \
        bash ~/.bin/import-ssh-from-1password.sh
      '';
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = true;

      format = lib.concatStrings [
        "$directory"
        "$git_branch"
        "$git_status"
        "$character"
      ];

      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };

  programs.tmux = {
    enable = true;
    prefix = "C-a";
    clock24 = true;
    mouse = false;
    terminal = "screen-256color";
    plugins = with pkgs.tmuxPlugins; [
      sensible
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-dir '~/.config/tmux/resurrect'
          set -g @resurrect-processes 'zsh bash nvim htop'
          set -g @resurrect-strategy-nvim 'session'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '1'  # w minutach
        '';
      }
    ];
  };

  systemd.user.services.tmux-autostart = {
    Unit = {
      Description = "Start tmux server on login";
      After = ["graphical-session.target"];
    };

    Service = {
      ExecStart = "${pkgs.tmux}/bin/tmux start-server";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = ["default.target"];
    };
  };

  programs.lazygit.enable = true;

  programs.git = {
    enable = true;
    userName = "Wojciech Kania";
    userEmail = "wojtek@kania.sh";

    signing = {
      key = "~/.ssh/keys/git_sign.pub";
      signByDefault = true;
    };

    extraConfig = {
      gpg.format = "ssh";
      commit.gpgSign = true;
      user.signingKey = "~/.ssh/keys/git_sign.pub";

      init.defaultBranch = "master";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };

  services.ssh-agent.enable = true;
  programs.ssh = {
    enable = true;

    addKeysToAgent = "yes";
    hashKnownHosts = true;
    compression = true;
    serverAliveInterval = 60;

    matchBlocks = {
      "github.com" = {
        user = "git";
        identityFile = "~/.ssh/keys/git_auth";
        identitiesOnly = true;
      };
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

  programs.ghostty = {
    enable = true;
    installVimSyntax = true;
    settings = {
      theme = "Monokai Pro Octagon";
      font-family = "TX-02 SemiCondensed";
      font-family-bold = "TX-02 Bold SemiCondensed";
      font-family-italic = "TX-02 Condensed SemiOblique";
      font-family-bold-italic = "TX-02 Bold SemiCondensed Oblique";
      font-size = 11;
    };
  };

  programs.firefox.enable = true;
  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;
    config = {
      modifier = "Mod4";
      input = {
        "*" = {
          xkb_layout = "pl";
          xkb_options = "caps:escape";
        };
      };
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
          "${modifier}+Q" = "kill";
        };
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.
}
