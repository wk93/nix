{pkgs, ...}: {
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd sway";
        user = "greeter";
      };
    };
  };

  users.users.greeter = {
    isSystemUser = true;
    description = "Greetd login user";
    home = "/var/lib/greetd";
    createHome = true;
    group = "greeter";
  };

  users.groups.greeter = {};

  environment.systemPackages = with pkgs; [
    greetd.tuigreet
  ];
}
