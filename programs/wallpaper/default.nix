{pkgs, ...}: let
  logo = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";

  wallpaper =
    pkgs.runCommand "rose-pine-nixos-wallpaper.png" {
      nativeBuildInputs = [pkgs.librsvg pkgs.imagemagick];
    } ''
      sed \
        -e 's/#7ebae4/#ebbcba/gI' \
        -e 's/#7eb1dd/#e5b1af/gI' \
        -e 's/#699ad7/#d9a3a1/gI' \
        -e 's/#5277c3/#c4a7e7/gI' \
        -e 's/#4a6baf/#b597da/gI' \
        -e 's/#415e9a/#a487c9/gI' \
        ${logo} > logo.svg
      rsvg-convert -w 720 -h 720 logo.svg -o logo.png
      magick -size 3840x2160 xc:'#191724' logo.png -gravity center -composite $out
    '';
in {
  home.packages = [pkgs.swaybg];

  wayland.windowManager.sway.config.output."*".bg = "${wallpaper} fill";
}
