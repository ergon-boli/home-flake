{pkgs, ...}: {
  # Git
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.git.enable
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    # Git large file storage support
    lfs = {
      enable = true;
    };
    ignores = [
      ".old"
      ".tmp"
      "*~"
      ".DS_Store"
    ];
    settings.user.name = "bOli";
    settings.user.email = "github.profile@bueechi.net";
    settings.alias = {
      a = "add";
      aa = "add --all";
      ap = "add -p";
      b = "branch";
      c = "commit";
      cam = "commit -a -m";
      can = "commit --amend --no-edit";
      cb = "checkout -b";
      cl = "clone";
      cm = "commit -m";
      co = "checkout";
      d = "diff";
      ds = "diff --staged";
      f = "fetch";
      l = "log --graph --oneline --decorate";
      p = "pull";
      pf = "push --force-with-lease";
      ph = "push";
      r = "reset";
      ra = "rebase --abort";
      rb = "rebase";
      rc = "rebase --continue";
      rH = "reset --hard";
      ri = "rebase -i";
      rst = "restore";
      s = "status";
      sp = "stash pop";
      st = "stash";
      sts = "stash show -p";
      stx = "stash drop";
      sw = "switch";
      swc = "switch -c";
      t = "tag";
      us = "restore --staged";
      uc = "reset --soft HEAD~1";
    };
  };
  # Enhanced diffs
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      side-by-side = false;
      navigate = true;
      line-numbers = true;
      syntax-theme = "TwoDark";
      tabs = 4;
    };
  };
}
