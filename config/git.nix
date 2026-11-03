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
    settings.pull.rebase = true;
    settings.init.defaultBranch = "main";
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
  # Inline diffs: delta as the pager for both git and jj
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    enableJujutsuIntegration = true;
    options = {
      side-by-side = false;
      navigate = true;
      line-numbers = true;
      tabs = 4;
      # print straight into the scrollback, however long; for long diffs, run hunk (hd) by hand
      paging = "never";
      syntax-theme = "Solarized (dark)";
      # compact, hunk-like layout: no hunk header boxes, no file rule or Δ
      hunk-header-style = "omit";
      file-decoration-style = "none";
      file-style = "#93a1a1 bold";
      file-modified-label = "";
      keep-plus-minus-markers = true;
      # line-number gutter as a base02 panel, numbers coloured by line type;
      # left/right-style paint the ⋮/│ separators in the panel colour
      line-numbers-zero-style = "#586e75 #073642";
      line-numbers-minus-style = "#dc322f #073642";
      line-numbers-plus-style = "#859900 #073642";
      line-numbers-left-style = "#073642 #073642";
      line-numbers-right-style = "#073642 #073642";
    };
  };
  # [hunk](https://github.com/modem-dev/hunk) for deliberate reviews (hd, hunk show, hunk-walk)
  programs.hunk = {
    enable = true;
    enableGitIntegration = false;
    settings = {
      theme = "auto";
      mode = "stack";
      line_numbers = true;
      wrap_lines = true;
      agent_notes = true;
      hunk_headers = false;
    };
  };
}
