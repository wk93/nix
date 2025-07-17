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
    _1password-cli
    _1password-gui-beta
    spotify
    unzip
    zip
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
      {
        plugin = rose-pine;
        extraConfig = ''
          set -g @rose_pine_variant 'main'
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
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };

  programs.ghostty = {
    enable = true;
    installVimSyntax = true;
    settings = {
      theme = "rose-pine";
      font-family = "TX-02 SemiCondensed";
      font-family-bold = "TX-02 Bold SemiCondensed";
      font-family-italic = "TX-02 Condensed SemiOblique";
      font-family-bold-italic = "TX-02 Bold SemiCondensed Oblique";
      font-size = 15;
    };
  };

  services.kanshi = {
    enable = true;
    settings = [
      {
        profile = {
          name = "undocked";
          outputs = [
            {
              criteria = "eDP-1";
              scale = 1.5;
            }
          ];
          exec = [
            ''${pkgs.sway}/bin/swaymsg "workspace 1, move workspace to output eDP-1"''
            ''${pkgs.sway}/bin/swaymsg "workspace 2, move workspace to output eDP-1"''
            ''${pkgs.sway}/bin/swaymsg "workspace 1"''
          ];
        };
      }

      {
        profile = {
          name = "docked";
          outputs = [
            {
              criteria = "eDP-1";
              scale = 1.5;
              position = "0,1440";
            }
            {
              criteria = "Dell Inc. DELL P2715Q V7WP95B5595S";
              scale = 1.5;
              position = "0,0";
            }
          ];
          exec = [
            ''${pkgs.sway}/bin/swaymsg "workspace 1, move workspace to output eDP-1"''
            ''${pkgs.sway}/bin/swaymsg "workspace 2, move workspace to output DP-2"''
            ''${pkgs.sway}/bin/swaymsg "workspace 1"''
          ];
        };
      }
    ];
  };

  programs.firefox = {
    enable = true;
    policies = {
      BlockAboutConfig = true;
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableFirefoxAccounts = true;
      DisableFeedbackCommands = true;
      DisableFormHistory = true;
      DisablePasswordReveal = true;
      DisableProfileImport = true;
      DisableSystemAddonUpdate = true;
      DisableEncryptedClientHello = true;
      DisableFirefoxScreenshots = true;
      DisableMasterPasswordCreation = true;
      DisableAppUpdate = true;

      HttpsOnlyMode = true;

      DNSOverHTTPS = {
        Enabled = true;
        ProviderURL = "https://base.dns.mullvad.net/dns-query";
      };

      EnableTrackingProtection = {
        Value = "always";
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };

      SearchSuggestEnabled = false;
      SearchEngines.PreventInstalls = true;
      OfferToSaveLogins = false;
      PasswordManagerEnabled = false;

      EncryptedMediaExtensions = {
        Enabled = false;
      };

      SearchEngines = {
        Add = [
          {
            Name = "Mullvad Leta";
            URLTemplate = "https://leta.mullvad.net/search?q={searchTerms}&engine=google";
            Method = "GET";
            Alias = "ml";
            IconURL = "https://leta.mullvad.net/favicon.ico";
            SuggestURLTemplate = "https://leta.mullvad.net/suggest?q={searchTerms}";
            Hidden = false;
          }
        ];
        Default = "Mullvad Leta";
        Remove = ["Bing" "DuckDuckGo" "eBay" "Wikipedia (en)" "Google"];
      };

      FirefoxHome = {
        Search = false;
        TopSites = false;
        SponsoredTopSites = false;
        Highlights = false;
        Pocket = false;
        SponsoredPocket = false;
        Snippets = false;
        Locked = true;
      };

      ExtensionSettings = {
        "*".installation_mode = "blocked";

        # uBlock Origin:
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
          private_browsing = true;
        };

        # Privacy Badger:
        "jid1-MnnxcxisBPnSXQ@jetpack" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
          installation_mode = "force_installed";
          private_browsing = true;
        };

        # 1Password:
        "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
          installation_mode = "force_installed";
          default_area = "navbar";
          private_browsing = true;
        };

        # Firefox Color
        "firefoxcolor@mozilla.com" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/firefox-color/latest.xpi";
          installation_mode = "force_installed";
          private_browsing = true;
        };
      };
    };
    profiles = {
      "default" = {
        extraConfig = ''
          user_pref("network.trr.mode", 3);
          user_pref("network.trr.uri", "https://base.dns.mullvad.net/dns-query");
          user_pref("network.trr.bootstrapAddress", "194.242.2.4");
        '';
      };
    };
  };

  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;
    config = {
      modifier = "Mod4";
      window = {
        titlebar = false;
        border = 0;
      };
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
          "${modifier}+P" = "exec 1password";
          "${modifier}+Q" = "kill";

          #T480 functional keys
          "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
          "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -10%";
          "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +10%";
          "XF86AudioMicMute" = "exec pactl set-source-mute @DEFAULT_SOURCE@ toggle";
          "XF86MonBrightnessDown" = "exec brightnessctl -q set 10%-";
          "XF86MonBrightnessUp" = "exec brightnessctl -q set +10%";
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
