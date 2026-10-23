{pkgs, ...}: {
  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";
  # waybar clock uses pl_PL
  i18n.extraLocales = ["pl_PL.UTF-8/UTF-8"];
  console = {
    earlySetup = true;
    packages = with pkgs; [terminus_font];
    font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
    keyMap = "pl2";
  };
}
