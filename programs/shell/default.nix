{pkgs, ...}: {
  home.packages = with pkgs; [
    ripgrep
    fd
    jq
    yq-go
    gh
  ];

  # ls/ll/la/lt
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
    git = true;
    extraOptions = ["--group-directories-first"];
  };

  programs.bat = {
    enable = true;
    config.theme = "rose-pine";
    themes.rose-pine = {
      src = pkgs.fetchFromGitHub {
        owner = "rose-pine";
        repo = "tm-theme";
        rev = "6d556734541ccb04172e81fd58de4a35fff72d19";
        hash = "sha256-5+fG21KbB7bdPvszkz9Ftl6fCDGs17fJNTAXFRFWZGo=";
      };
      file = "dist/rose-pine.tmTheme";
    };
  };

  programs.zsh.shellAliases.cat = "bat --paging=never --style=plain";

  home.sessionVariables.MANPAGER = "sh -c 'col -bx | bat -l man -p'";

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
      syntax-theme = "rose-pine";
    };
  };

  programs.lazygit.settings.git.diffRenderers = [
    {command = "delta --dark --paging=never";}
  ];

  # Ctrl+T files, Alt+C dirs; Ctrl+R handled by atuin
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    historyWidget.command = "";
    defaultCommand = "fd --type f --hidden --exclude .git";
    fileWidget.command = "fd --type f --hidden --exclude .git";
    changeDirWidget.command = "fd --type d --hidden --exclude .git";
    colors = {
      fg = "#908caa";
      bg = "-1";
      hl = "#ebbcba";
      "fg+" = "#e0def4";
      "bg+" = "#26233a";
      "hl+" = "#ebbcba";
      border = "#403d52";
      header = "#31748f";
      gutter = "-1";
      spinner = "#f6c177";
      info = "#9ccfd8";
      pointer = "#c4a7e7";
      marker = "#eb6f92";
      prompt = "#908caa";
    };
  };

  # cd learns visited dirs: `cd proj` jumps, `cdi` picks interactively
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = ["--cmd cd"];
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = ["--disable-up-arrow"];
    settings = {
      style = "compact";
      inline_height = 20;
      update_check = false;
    };
  };
}
