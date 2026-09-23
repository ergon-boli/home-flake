{...}: {
  # Jujutsu, a git-compatible VCS
  # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.jujutsu.enable
  # Identity and work-specific revsets live in the consumer, like the git identity.
  programs.jujutsu = {
    enable = true;
    settings = {
      ui.default-command = ["log" "--no-pager"];

      # show the current work plus all truly local commits: `immutable_heads()..`
      # is the unpushed work, and stays small as long as stale local branches get
      # cleaned up now and then (see the `stale` alias below). For the narrow view
      # of just the current line, use `jj l -r 'line()'`.
      revsets.log = "present(@) | ancestors(immutable_heads().., 2) | present(trunk())";

      # non-unique remainder of change/commit ids; the default "bright black"
      # is invisible on Solarized Dark (bright black = base03 = background).
      # base02 = #073642, base01 = #586e75, base00 = #657b83 (dark → light)
      colors.rest = "#586e75";

      aliases = {
        l = ["--no-pager" "log"];
        ss = ["show" "--summary" "--no-pager"];
        dn = ["diff" "--name-only" "--no-pager" "-r"];
      };

      revset-aliases = {
        # "local-only commits not in my current line of work" — the cleanup
        # candidates: `jj l -r stale`, or `jj l -r 'heads(stale)'` for just the tips.
        stale = "mutable() ~ ::@";

        # my own stale commits (excludes colleagues' fetched-and-orphaned work)
        strays = "stale & mine()";

        # the narrow log view: just the current line relative to trunk
        "line()" = "present(@) | ancestors(trunk()..@, 2) | present(trunk())";
      };
    };
  };
}
