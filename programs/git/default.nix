{config, ...}: let
  name = config.var.git.name;
  email = config.var.git.email;
in {
  programs.git = {
    enable = true;

    signing = {
      key = "~/.ssh/keys/git_sign.pub";
      signByDefault = true;
    };

    settings = {
      user = {
        name = name;
        email = email;
      };
      gpg.format = "ssh";
      commit.gpgSign = true;
      user.signingKey = "~/.ssh/keys/git_sign.pub";

      init.defaultBranch = "master";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };
}
