{pkgs, ...}: {
  home.packages = with pkgs; [
    # CLI Basics
    eza # Better `ls`
    fd # Better `find`
    fzf # A fuzzy finder
    jq # command line JSON processor
    ripgrep # Better `grep`
    zoxide # Better `cd`
    #topgrade # meta update tool, does not compile currently, thus installed using brew

    # Development
    pandoc # Convert formats, e.g. between markdown and jira
    rustup # Rust lang tools

    (nerdfonts.override {fonts = ["JetBrainsMono" "SourceCodePro"];})
  ];

  programs = {
    # Starship Prompt
    # https://rycee.gitlab.io/home-manager/options.html#opt-programs.starship.enable
    starship = {
      enable = true;
      enableZshIntegration = false;
      enableFishIntegration = true;
      # Configuration is written to ~/.config/starship.toml
      settings = {
        directory.truncate_to_repo = false; # show the path above the current repo too
        directory.fish_style_pwd_dir_length = 1; # turn on fish directory truncation
        directory.truncation_length = 3; # number of directories not to truncate
        battery.disabled = true; # Work around bug in sharship v1.16.0 https://github.com/starship/starship/issues/5350
      };
    };

    # Bat, a substitute for cat.
    # https://github.com/sharkdp/bat
    # https://rycee.gitlab.io/home-manager/options.html#opt-programs.bat.enable
    bat = {
      enable = true;
      config = {
        style = "plain";
        theme = "TwoDark";
        italic-text = "always";
      };
    };

    # See https://github.com/alacritty/alacritty/blob/master/alacritty.yml for example (normal) config
    alacritty = {
      enable = true;
      settings = {
        font = rec {
          normal.family = "SauceCodePro Nerd Font Mono";
          bold = {style = "Bold";};
          size = 13;
        };
        offset = {
          x = 0;
          y = 0;
        };
      };
    };
  };

  nix.hmConfigDir = "~/Documents/nix-home";
  nix.hmBaseFlake = "home-flake";
}
