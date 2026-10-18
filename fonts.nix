{
  config,
  pkgs,
  ...
}: let
  tx02 = pkgs.stdenvNoCC.mkDerivation {
    name = "tx-02";
    src = builtins.path {
      path = ./secrets/fonts/TX-02;
      name = "berkley-mono-tx-02";
    };

    dontPatch = true;
    dontConfigure = true;
    dontBuild = true;
    doCheck = false;

    installPhase = ''
      runHook preInstall
      install -Dm644 -t $out/share/fonts/opentype/ *.otf
      runHook postInstall
    '';
  };
in {
  home.packages = [tx02];

  fonts.fontconfig.enable = true;
}
