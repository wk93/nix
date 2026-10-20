{pkgs, ...}: let
  # clipboard bridge for iPhone Shortcuts over ssh
  # in: text, img: base64 image, out: text or data:image/png;base64,...
  clip = pkgs.writeShellApplication {
    name = "clip";
    runtimeInputs = [pkgs.wl-clipboard pkgs.pandoc pkgs.file pkgs.libheif.bin];
    text = ''
      export XDG_RUNTIME_DIR=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
      export WAYLAND_DISPLAY=''${WAYLAND_DISPLAY:-wayland-1}
      case "''${SSH_ORIGINAL_COMMAND:-''${1:-}}" in
        in)
          tmp=$(mktemp -d)
          trap 'rm -rf "$tmp"' EXIT
          cat >"$tmp/in"
          # Shortcuts sometimes sends a photo here; bash vars would drop NULs
          if [[ $(file -b --mime-type "$tmp/in") == image/* ]]; then
            SSH_ORIGINAL_COMMAND=img exec "$0" < <(base64 -w0 "$tmp/in")
          fi
          # sentinel keeps trailing newlines
          data=$(tr -d '\0' <"$tmp/in"; printf x)
          data=''${data%x}
          # RTFD bundle: keep only the embedded TXT.rtf
          if [[ $data == rtfd* && $data == *'{\rtf'* ]]; then
            data="{\\rtf''${data#*\{\\rtf}"
            data="''${data%\}*}}"
          fi
          # Shortcuts sends rich text as RTF
          if [[ $data == '{\rtf'* ]]; then
            data=$(printf '%s' "$data" | pandoc -f rtf -t plain --wrap=none)
          fi
          printf '%s' "$data" | wl-copy --type text/plain >/dev/null 2>&1
          ;;
        img)
          tmp=$(mktemp -d)
          trap 'rm -rf "$tmp"' EXIT
          base64 -d -i >"$tmp/img"
          mime=$(file -b --mime-type "$tmp/img")
          if [[ $mime == image/hei[cf] ]]; then
            heif-dec "$tmp/img" "$tmp/img.png" >/dev/null
            mv "$tmp/img.png" "$tmp/img"
            mime=image/png
          fi
          if [[ $mime != image/* ]]; then
            echo "not an image: $mime" >&2
            exit 1
          fi
          # file managers can't paste raw image data, so keep a copy on disk
          dir=$HOME/Pictures/iphone
          mkdir -p "$dir"
          cp "$tmp/img" "$dir/iphone-$(date +%Y%m%d-%H%M%S).''${mime#image/}"
          wl-copy --type "$mime" <"$tmp/img" >/dev/null 2>&1
          ;;
        out)
          types=$(wl-paste --list-types)
          for t in 'text/plain;charset=utf-8' UTF8_STRING text/plain; do
            if grep -qxF "$t" <<<"$types"; then
              exec wl-paste --no-newline --type "$t"
            fi
          done
          if grep -qxF image/png <<<"$types"; then
            printf 'data:image/png;base64,'
            wl-paste --type image/png | base64 -w0
            exit 0
          fi
          echo "no text or image in clipboard" >&2
          exit 1
          ;;
        *)
          echo "usage: clip in|img|out" >&2
          exit 1
          ;;
      esac
    '';
  };
in {
  # Define a user account
  users.users.wojtek = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "video" "audio"];
    hashedPassword = "$6$rFEKCWBXwA.62ha/$APg2bkmM/X7Ei50IYIu6SKN0SfCPC2ZlF/Dni2AZxTbo9FhGE809ifqffmRtmGf1XcKYk38sjbMni2MgQxq1g/";
    openssh.authorizedKeys.keys = [
      ''restrict,command="${clip}/bin/clip" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJudFRYTjf3Vk874ZjFNO4V9RTaS1YapS3Y25Bmcs8LQ iphone-shortcuts''
    ];
  };

  environment.systemPackages = [clip];
}
