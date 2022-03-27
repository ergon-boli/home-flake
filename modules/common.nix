{ pkgs, ... }: {

  home.packages = with pkgs; [
    # CLI Basics
    exa # Better `ls`
    fd # Better `find`
    fzf # A fuzzy finder
    ripgrep # Better `grep`
    
    # Development
    pandoc # Convert formats, e.g. between markdown and jira
    rustup # Rust lang tools
    
    (nerdfonts.override { fonts = [ "JetBrainsMono" "SourceCodePro" ]; })
  ];
  
  programs = {
  
  	home-manager.enable = true;
  	
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
  };
}
