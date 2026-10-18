{config, ...}: let
  name = config.var.git.name;
  email = config.var.git.email;
  signingPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII7m6r15E4iMooTSqgWN3Qr0AxNEbG4pa/eH3NXPynZ0";
in {
  xdg.configFile."git/allowed_signers".text = ''
    ${email} ${signingPubKey}
  '';

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
      gpg.ssh.allowedSignersFile = "${config.xdg.configHome}/git/allowed_signers";
      commit.gpgSign = true;
      user.signingKey = "~/.ssh/keys/git_sign.pub";

      init.defaultBranch = "master";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };
}
