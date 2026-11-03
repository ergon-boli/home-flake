{...}: {
  # Jujutsu, a git-compatible VCS
  # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.jujutsu.enable
  # Identity and work-specific revsets live in the consumer, like the git identity.
  programs.jujutsu = {
    enable = true;
    settings = {
      ui.default-command = ["log" "--no-pager"];

      # move a main bookmark along with `jj commit`/`jj new`, as git does on a branch
      experimental-advance-branches.enabled-branches = ["main"];

      # show the current work plus all truly local commits: `immutable_heads()..`
      # is the unpushed work, and stays small as long as stale local branches get
      # cleaned up now and then (see the `stale` alias below). For the narrow view
      # of just the current line, use `jj log -r 'line()'`. Trunk also shows my own
      # commits of the last 24 hours (by author date, which rewrites keep) plus the
      # one below them, so freshly pushed work and its base stay visible.
      revsets.log = "present(@) | ancestors(immutable_heads().., 2) | ancestors((::present(trunk()) & mine() & author_date(after:\"1 day ago\")) | present(trunk()), 2)";

      # non-unique remainder of change/commit ids; the default "bright black"
      # is invisible on Solarized Dark (bright black = base03 = background).
      # base02 = #073642, base01 = #586e75, base00 = #657b83 (dark → light)
      colors.rest = "#586e75";

      revset-aliases = {
        # "local-only commits not in my current line of work" — the cleanup
        # candidates: `jj log -r stale`, or `jj log -r 'heads(stale)'` for just the tips.
        stale = "mutable() ~ ::@";

        # my own stale commits (excludes colleagues' fetched-and-orphaned work)
        strays = "stale & mine()";

        # the narrow log view: just the current line relative to trunk
        "line()" = "present(@) | ancestors(trunk()..@, 2) | present(trunk())";
      };
    };
  };
}
