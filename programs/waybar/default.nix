{
  pkgs,
  lib,
  ...
}: let
  nvidiaStatus = pkgs.writeShellScript "waybar-nvidia" ''
    export PATH=${lib.makeBinPath [pkgs.coreutils pkgs.gawk pkgs.jq]}:/run/current-system/sw/bin
    dev=/sys/bus/pci/devices/0000:01:00.0
    if [ ! -e "$dev" ] || [ "$(cat $dev/power/runtime_status)" = suspended ] || ! command -v nvidia-smi >/dev/null; then
      echo '{"text": ""}'
      exit 0
    fi
    IFS=', ' read -r util temp mem pstate < <(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,memory.used,pstate --format=csv,noheader,nounits)
    procs=$(nvidia-smi | awk '$1 == "|" && $5 ~ /^[0-9]+$/ && $6 ~ /^(C|G|C\+G)$/ { n = split($7, p, "/"); print p[n] " (" $8 ")" }')
    if [ -n "$procs" ]; then
      class=active
      text="󰢮 $util%"
    else
      class=idle
      text="󰢮"
      procs="no processes"
    fi
    jq -cn --arg text "$text" --arg class "$class" \
      --arg tooltip "MX150  $pstate  $temp°C  $util%  $mem MiB"$'\n'"$procs" \
      '{text: $text, class: $class, tooltip: $tooltip}'
  '';
in {
  home.packages = [pkgs.nerd-fonts.symbols-only pkgs.networkmanager_dmenu];

  xdg.configFile."networkmanager-dmenu/config.ini".text = ''
    [dmenu]
    dmenu_command = rofi -dmenu -i
    wifi_chars = ▂▄▆█

    [editor]
    terminal = ghostty
    gui_if_available = false
  '';

  wayland.windowManager.sway.config.bars = [];

  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      targets = ["sway-session.target"];
    };

    settings.main = {
      layer = "top";
      position = "top";
      height = 28;
      spacing = 0;

      modules-left = [
        "sway/workspaces"
        "sway/mode"
        "sway/scratchpad"
        "sway/window"
      ];
      modules-center = ["clock"];
      modules-right = [
        "privacy"
        "systemd-failed-units"
        "group/sys"
        "network"
        "bluetooth"
        "group/av"
        "group/power"
        "tray"
      ];

      "sway/workspaces" = {
        disable-scroll = true;
        format = "{name}";
      };

      "sway/mode".format = "{}";

      "sway/scratchpad" = {
        format = "󰌨 {count}";
        show-empty = false;
        tooltip-format = "{app}: {title}";
      };

      "sway/window" = {
        max-length = 40;
        format = "{title}";
        tooltip = false;
      };

      clock = {
        interval = 1;
        format = "{:%a %d.%m  %H:%M}";
        format-alt = "{:%Y-%m-%d  W%V  %H:%M:%S}";
        locale = "pl_PL.UTF-8";
        tooltip-format = "{calendar}";
        calendar = {
          mode = "month";
          weeks-pos = "left";
          on-scroll = 1;
          format = {
            months = "<span color='#ebbcba'><b>{}</b></span>";
            weekdays = "<span color='#908caa'>{}</span>";
            weeks = "<span color='#6e6a86'>{}</span>";
            days = "<span color='#e0def4'>{}</span>";
            today = "<span color='#191724' background='#f6c177'><b>{}</b></span>";
          };
        };
        actions = {
          on-click-right = "mode";
          on-scroll-up = "shift_up";
          on-scroll-down = "shift_down";
        };
      };

      privacy = {
        icon-size = 13;
        icon-spacing = 6;
        transition-duration = 200;
        modules = [
          {type = "screenshare";}
          {type = "audio-in";}
        ];
      };

      "systemd-failed-units" = {
        hide-on-ok = true;
        system = true;
        user = true;
        format = "󰀦 {nr_failed}";
        tooltip-format = "system {nr_failed_system}  user {nr_failed_user}";
        on-click = "ghostty -e sh -c 'systemctl --failed; systemctl --user --failed; read'";
      };

      "group/sys" = {
        orientation = "inherit";
        modules = ["cpu" "memory" "temperature" "custom/nvidia"];
      };

      "custom/nvidia" = {
        exec = "${nvidiaStatus}";
        return-type = "json";
        interval = 5;
        hide-empty-text = true;
      };

      cpu = {
        interval = 3;
        format = "󰻠 {usage}%";
        tooltip-format = "load {load}  avg {avg_frequency} GHz";
        states = {
          warning = 70;
          critical = 90;
        };
      };

      memory = {
        interval = 5;
        format = "󰍛 {used:0.1f}G";
        tooltip-format = "RAM {used:0.1f} / {total:0.0f} GiB ({percentage}%)\nswap {swapUsed:0.1f} / {swapTotal:0.0f} GiB";
        states = {
          warning = 70;
          critical = 90;
        };
      };

      temperature = {
        hwmon-path-abs = "/sys/devices/platform/coretemp.0/hwmon";
        input-filename = "temp1_input";
        interval = 3;
        warning-threshold = 75;
        critical-threshold = 88;
        format = "{icon} {temperatureC}°";
        format-icons = ["" "" ""];
        tooltip-format = "CPU package {temperatureC}°C";
      };

      network = {
        interval = 5;
        format-wifi = "{icon} {essid}";
        format-ethernet = "󰈀 {ipaddr}";
        format-linked = "󰈀 no ip";
        format-disconnected = "󰤮 offline";
        format-disabled = "󰤮 off";
        format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
        max-length = 18;
        tooltip-format-wifi = "{essid}  {signalStrength}%  {signaldBm} dBm  {frequency} GHz\n{ifname}  {ipaddr}/{cidr} via {gwaddr}\n↓ {bandwidthDownBytes}  ↑ {bandwidthUpBytes}";
        tooltip-format-ethernet = "{ifname}  {ipaddr}/{cidr} via {gwaddr}\n↓ {bandwidthDownBytes}  ↑ {bandwidthUpBytes}";
        tooltip-format-disconnected = "disconnected";
        on-click = "networkmanager_dmenu";
        on-click-right = "ghostty -e nmtui";
      };

      bluetooth = {
        format = "󰂯";
        format-disabled = "󰂲";
        format-off = "󰂲";
        format-connected = "󰂱 {device_alias}";
        format-connected-battery = "󰂱 {device_alias} {device_battery_percentage}%";
        max-length = 18;
        tooltip-format = "{controller_alias}  {status}";
        tooltip-format-connected = "{controller_alias}  {num_connections} connected\n{device_enumerate}";
        tooltip-format-enumerate-connected = "{device_alias}  {device_address}";
        tooltip-format-enumerate-connected-battery = "{device_alias}  {device_battery_percentage}%";
        on-click = "blueman-manager";
        on-click-right = "bluetoothctl power toggle";
      };

      "group/av" = {
        orientation = "inherit";
        modules = ["pulseaudio" "pulseaudio#mic" "backlight"];
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "󰝟 mute";
        format-icons = {
          headphone = "󰋋";
          headset = "󰋋";
          default = ["󰕿" "󰖀" "󰕾"];
        };
        scroll-step = 5;
        max-volume = 150;
        tooltip-format = "{desc}";
        on-click = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
        on-click-right = "pavucontrol";
      };

      "pulseaudio#mic" = {
        format = "{format_source}";
        format-muted = "{format_source}";
        format-source = "󰍬";
        format-source-muted = "󰍭";
        tooltip-format = "{source_desc}  {source_volume}%";
        on-click = "pactl set-source-mute @DEFAULT_SOURCE@ toggle";
        on-click-right = "pavucontrol -t 4";
        on-scroll-up = "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SOURCE@ 5%+";
        on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-";
      };

      backlight = {
        device = "intel_backlight";
        format = "{icon} {percent}%";
        format-icons = ["󰃞" "󰃟" "󰃠"];
        on-scroll-up = "brightnessctl -q set +5%";
        on-scroll-down = "brightnessctl -q -n 30 set 5%-";
        tooltip = false;
      };

      "group/power" = {
        orientation = "inherit";
        modules = ["battery" "idle_inhibitor"];
      };

      battery = {
        adapter = "AC";
        interval = 30;
        states = {
          warning = 25;
          critical = 12;
        };
        format = "{icon} {capacity}%";
        format-discharging = "{icon} {capacity}% {time}";
        format-charging = "󰂄 {capacity}%";
        format-plugged = "󰚥 {capacity}%";
        format-full = "󰚥 full";
        format-alt = "{icon} {power:.1f}W {time}";
        format-time = "{H}:{m}";
        format-icons = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
        tooltip-format = "{timeTo}\n{power:.1f} W  min health {health}%";
      };

      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
          activated = "󰅶";
          deactivated = "󰛊";
        };
        tooltip-format-activated = "idle lock off";
        tooltip-format-deactivated = "idle lock on";
      };

      tray = {
        icon-size = 15;
        spacing = 8;
      };
    };

    style = ''
      @define-color base #191724;
      @define-color surface #1f1d2e;
      @define-color overlay #26233a;
      @define-color muted #6e6a86;
      @define-color subtle #908caa;
      @define-color text #e0def4;
      @define-color love #eb6f92;
      @define-color gold #f6c177;
      @define-color rose #ebbcba;
      @define-color pine #31748f;
      @define-color foam #9ccfd8;
      @define-color iris #c4a7e7;
      @define-color hlmed #403d52;

      * {
        font-family: "TX-02 SemiCondensed", "Symbols Nerd Font Mono";
        font-size: 13px;
        min-height: 0;
        border: none;
        border-radius: 0;
      }

      window#waybar {
        background: alpha(@base, 0.94);
        color: @text;
        border-bottom: 1px solid @overlay;
      }

      tooltip {
        background: @surface;
        border: 1px solid @hlmed;
        border-radius: 6px;
      }

      tooltip label {
        color: @text;
        padding: 2px 4px;
      }

      #workspaces button {
        padding: 0 9px;
        color: @muted;
        background: transparent;
        box-shadow: inset 0 -2px transparent;
      }

      #workspaces button:hover {
        background: @overlay;
        color: @text;
      }

      #workspaces button.visible {
        color: @subtle;
      }

      #workspaces button.focused {
        color: @rose;
        background: @surface;
        box-shadow: inset 0 -2px @rose;
      }

      #workspaces button.urgent {
        color: @base;
        background: @love;
      }

      #mode {
        margin: 4px 6px;
        padding: 0 8px;
        border-radius: 4px;
        background: @iris;
        color: @base;
      }

      #scratchpad {
        padding: 0 8px;
        color: @foam;
      }

      #window {
        padding: 0 10px;
        color: @subtle;
      }

      #clock {
        padding: 0 12px;
        font-family: "TX-02 Bold SemiCondensed", "Symbols Nerd Font Mono";
      }

      #privacy,
      #systemd-failed-units,
      #sys,
      #network,
      #bluetooth,
      #av,
      #power,
      #tray {
        margin: 4px 0 4px 6px;
        border-radius: 5px;
        background: @surface;
      }

      #tray {
        margin-right: 6px;
        padding: 0 8px;
      }

      #privacy,
      #systemd-failed-units,
      #cpu,
      #memory,
      #temperature,
      #custom-nvidia,
      #network,
      #bluetooth,
      #pulseaudio,
      #backlight,
      #battery,
      #idle_inhibitor {
        padding: 0 7px;
      }

      #privacy,
      #systemd-failed-units {
        color: @base;
        background: @love;
      }

      #privacy-item {
        color: @base;
      }

      #cpu,
      #memory {
        color: @foam;
      }

      #temperature {
        color: @subtle;
      }

      #network {
        color: @iris;
      }

      #network.disconnected,
      #network.disabled {
        color: @muted;
      }

      #custom-nvidia.idle {
        color: @muted;
      }

      #custom-nvidia.active {
        color: @pine;
      }

      #bluetooth {
        color: @foam;
      }

      #bluetooth.disabled,
      #bluetooth.off,
      #bluetooth.no-controller {
        color: @muted;
      }

      #bluetooth.connected {
        color: @iris;
      }

      #pulseaudio {
        color: @rose;
      }

      #pulseaudio.muted {
        color: @muted;
      }

      #pulseaudio.mic {
        padding: 0 4px;
        color: @subtle;
      }

      #pulseaudio.mic.source-muted {
        color: @love;
      }

      #backlight {
        color: @gold;
      }

      #battery {
        color: @text;
      }

      #battery.charging,
      #battery.plugged,
      #battery.full {
        color: @foam;
      }

      #cpu.warning,
      #memory.warning,
      #temperature.warning,
      #battery.discharging.warning {
        color: @gold;
      }

      #cpu.critical,
      #memory.critical,
      #temperature.critical {
        color: @love;
      }

      #battery.discharging.critical {
        color: @base;
        background: @love;
        border-radius: 5px;
        animation: blink 1s steps(2) infinite alternate;
      }

      @keyframes blink {
        to {
          background: alpha(@love, 0.4);
        }
      }

      #idle_inhibitor {
        color: @muted;
      }

      #idle_inhibitor.activated {
        color: @base;
        background: @iris;
        border-radius: 5px;
      }

      #tray > .needs-attention {
        background: @love;
        border-radius: 4px;
      }
    '';
  };
}
