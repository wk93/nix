{
  config,
  lib,
  ...
}: {
  config.var = {
    git = {
      name = "Wojciech Kania";
      email = "wojtek@kania.sh";
    };
  };

  options = {
    var = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
  };
}
