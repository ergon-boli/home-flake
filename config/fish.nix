{pkgs, ...}: {
  # Add Fish plugins
  home.packages = [pkgs.fishPlugins.done];

  programs.fish = {
    enable = true;
    plugins = [
      # Need this when using Fish as a default macOS shell in order to pick
      # up ~/.nix-profile/bin
      {
        name = "nix-env";
        src = pkgs.fetchFromGitHub {
          owner = "lilyball";
          repo = "nix-env.fish";
          rev = "00c6cc762427efe08ac0bd0d1b1d12048d3ca727";
          sha256 = "1hrl22dd0aaszdanhvddvqz3aq40jp9zi2zn0v1hjnf7fx4bgpma";
        };
      }
    ];
    shellInit = ''
      # Set syntax highlighting colours; var names defined here:
      # http://fishshell.com/docs/current/index.html#variables-color
      set fish_color_autosuggestion brblack
      source ~/.config/fish/environment
      zoxide init fish | source
    '';
    shellAliases = {
      # safety
      rm = "rm -i";
      cp = "cp -i";
      mv = "mv -i";

      # convenience
      mkdir = "mkdir -p";
      du = "du -hs";
      sha256 = "shasum -a 256 ";
      m2j = "pbpaste | pandoc --from markdown --to jira | pbcopy";

      # replace some defaults
      cat = "bat";
      ls = "eza";
      la = "eza -alg";
      ll = "eza -lg";

      # cd to important dirs
      DL = "cd ~/Downloads";
      nd = "cd ~/Documents/NAS/docu";
      wk = "cd ~/work";
      ws = "cd $WORKSPACE";
      pj = "cd $WORKSPACE/$PROJECT";
      te = "cd $WORKSPACE/taifun-evergreen";
      jtt = "cd $WORKSPACE/jtt";
      jet = "cd $WORKSPACE/jet";
      md = "set -g PROJECT taifun-evergreen/mnet && set -g WORKSPACE $WORKSPACES/mnet/devel/ && pj";
      mt = "set -g PROJECT taifun-evergreen/mnet && set -g WORKSPACE $WORKSPACES/mnet/test/ && pj";
      mp = "set -g PROJECT taifun-evergreen/mnet && set -g WORKSPACE $WORKSPACES/mnet/prod/ && pj";
      dts = "set -g PROJECT dtst && set -g WORKSPACE $WORKSPACES/dtst/devel/ && pj";
      wg = "cd ~/work/git_projects";
      gaf = "ws; ../git-all fetch; pj";
      gap = "ws; ../git-all pull; pj";
      gspp = "git stash && git pull && git stash pop";

      # edit important files
      sshc = "bbedit ~/.ssh/config";

      # Misc
      flush_dns = "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder";

      # Nix
      HF = "cd ~/Documents/nix-home/home-flake";
      s = "cd ~/Documents/nix-home && nix build && result/activate && source ~/.config/fish/config.fish";

      # x86_64 version of homebrew
      oldbrew = "/usr/local/bin/brew";
    };
    # Abbreviate commonly used functions
    # An abbreviation will expand after <space> or <Enter> is hit
    shellAbbrs = {
      b = "bat";
      d = "diskutil";
      g = "git";
      ga = "git add";
      gaa = "git add --all";
      gb = "git branch";
      gc = "git commit";
      gca = "git commit --amend";
      gcam = "git commit -a -m";
      gcan = "git commit --amend --no-edit";
      gcb = "git checkout -b";
      gcl = "git clone";
      gcm = "git commit -m";
      gco = "git checkout";
      gcp = "git cherry-pick";
      gd = "git diff";
      gds = "git diff --staged";
      gf = "git fetch";
      gl = "git log --graph --oneline --decorate";
      glp = "git prettylog";
      gp = "git pull";
      gpf = "git push --force-with-lease";
      gph = "git push";
      gr = "git reset";
      gra = "git rebase --abort";
      grb = "git rebase";
      grc = "git rebase --continue";
      grH = "git reset --hard";
      gri = "git rebase -i";
      grs = "git restore --staged";
      grst = "git restore";
      gs = "git status";
      gsp = "git stash pop";
      gst = "git stash";
      gsts = "git stash show -p";
      gstx = "git stash drop";
      gsw = "git switch";
      gswc = "git switch -c";
      gt = "git tag";
      gus = "git restore --staged";
      guc = "git reset --soft HEAD~1";
      v = "vim";
      yss = "yabai --start-service";
      yos = "yabai --stop-service";
      yrs = "yabai --restart-service";
    };
    functions = {
      fish_greeting = {
        description = "Greeting to show when starting a fish shell";
        body = "";
      };
      mkdcd = {
        description = "Make a directory tree and enter it";
        body = "mkdir -p $argv[1]; and cd $argv[1]";
      };
      yabai-hash-update = {
        description = "Updates the hash string in the yabai sudoers file";
        body = ''
          set hashString "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai) | cut -d ' ' -f 1) $(which yabai) --load-sa"
          sudo rm /private/etc/sudoers.d/yabai
          echo $hashString | sudo tee -a /private/etc/sudoers.d/yabai
          sudo chmod +x /private/etc/sudoers.d/yabai
        '';
      };
    };
  };
}
