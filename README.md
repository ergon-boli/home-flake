# home-flake
A nix home-manager flake to set up my stuff

This repo is a library, not a configuration. It exports home-manager modules (`homeManagerModules.base` and `.boli`), a `lib.homeConfigurations` helper and a consumer template — but no `packages`, so there is nothing to build here.

What you build is the consumer flake, one directory up (see [Step by step Nix install](#step-by-step-nix-install) to create it):

```sh
cd ~/Documents/nix-home
nix build
result/activate
```

## How this works

This repo started as a copy of [ciderale/home-flake](https://github.com/ciderale/home-flake) — its README explains the design in more depth. The `lib.homeConfigurations` helper, the `modules/` vs `config/` split and the `hm*` aliases all come from there.

The `hm*` aliases are defined in `modules/nixBase.nix` and switched on by `nix.hmConfigDir` / `nix.hmBaseFlake` in `config/common.nix`:

| alias | does |
| ----- | ---- |
| `hmCd` | jump to the consumer |
| `hmBuild` | build it |
| `hmPull` | re-lock just the `home-flake` input |
| `hmActivate` | activate whatever `result` currently points at |
| `hmSwitch` | build, then activate |
| `hmPullBuild` / `hmPullSwitch` | pull, then build / build and activate |
| `hmLocalBuild` / `hmLocalSwitch` | build (and activate) against the local checkout |

`hmActivate` is the shared last step of all three `*Switch` aliases. It stays separate from the build so the `Local` variants activate the result of their *overridden* build, rather than rebuilding without the override.

### Two repos, two jobs

|                         | this repo (`home-flake`)      | the consumer (`~/Documents/nix-home`) |
| ----------------------- | ----------------------------- | ------------------------------------- |
| role                    | shareable library             | the actual configuration              |
| holds                   | modules, config, template     | the input pin and per-machine settings|
| published               | yes                           | no                                    |
| git identity            | never set here                | set here, per machine                 |
| buildable               | no `packages` output          | `nix build` → `result/activate`       |

Keeping them apart is what lets one shared repo serve several machines (work and home) whose identity and extras differ.

* `modules/` add *options* and enable nothing by themselves — shareable.
* `config/` apply actual settings — personal, but still shared across my machines.

### How a build resolves

```
nix-home/flake.nix
  └─ home-flake.lib.homeConfigurations { default = "boli"; boli = {...}; }
       └─ home-manager.lib.homeManagerConfiguration
            ├─ homeManagerModules.base   (modules/nixBase.nix)
            ├─ homeManagerModules.boli   (hunk module + config/*.nix)
            └─ inline per-machine config (git user.name / user.email)
                 └─ activationPackage → packages.<system>.default
                      └─ result/ → result/activate
```

### Two loops

Changing config has to round-trip through GitHub, because the consumer pulls this repo from there — `hmLocalSwitch` is the shortcut that skips the trip while testing:

```
edit home-flake → hmLocalSwitch → commit → push → hmPullSwitch
```

Updating dependencies happens **only in the consumer**. Its lock is authoritative for every input, including the ones declared here, so `nixpkgs` and `hunk` are bumped there rather than in this repo:

```
hmCd && nix flake update && hmSwitch
```

### Which lock matters

`nix-home/flake.lock` decides what gets built. This repo's `flake.lock` is only a seed: for a fresh consumer, and for `--override-input` testing. Keep every declared input present in it (`nix flake lock` adds missing ones without bumping anything), or those two paths resolve against a cached HEAD lookup instead of a pin.

## Test local changes before publishing

The consumer flake one directory up pulls this repo from GitHub, so it only sees pushed changes. To try a local working copy first, override the input:

```sh
cd ~/Documents/nix-home
nix build --override-input home-flake path:$PWD/home-flake
result/activate
```

Notes:
- `path:` copies the working tree as-is, so uncommitted and untracked changes are included (`git+file://` would only see committed content).
- Inputs resolve from *this* repo's `flake.lock`, not the consumer's, so a local test can build against different pins than the real thing — watch the `• Updated input` lines Nix prints.
- The override is not written to `flake.lock`. Once you're happy, commit, push, and run a normal `nix flake update` in the consumer.
- Check what got built before activating, e.g. `cat result/home-files/.config/hunk/config.toml`.

----

# Step by step Nix install

## install nix
According to [the documentation](https://nixos.org/download/).

## install my stuff initially
Flakes aren't enabled yet at this point, hence the long-winded invocations. `git+https` rather than `github:` for the same reason as in the template itself — a rate-limited API lookup silently falls back to a cached, possibly stale revision.

```sh
mkdir -p ~/Documents/nix-home
cd ~/Documents/nix-home

/nix/var/nix/profiles/default/bin/nix --extra-experimental-features "nix-command flakes" \
  flake init -t git+https://github.com/ergon-boli/home-flake

# edit flake.nix as needed

/nix/var/nix/profiles/default/bin/nix --extra-experimental-features "nix-command flakes" \
  build
result/activate
```

To work on home-flake itself, clone it alongside the config — the local-testing section above assumes it sits at `~/Documents/nix-home/home-flake`:

```sh
cd ~/Documents/nix-home
git clone git@github.com:ergon-boli/home-flake.git
```

## enable fish shell
```sh
sudo echo "$HOME/.nix-profile/bin/fish" >> /etc/shells
chsh -s ~/.nix-profile/bin/fish
```

# Maintenance / usage tipps
## Update nix itself
```sh
sudo -i sh -c 'nix-channel --update && nix-env -iA nixpkgs.nix && launchctl remove org.nixos.nix-daemon && launchctl load /Library/LaunchDaemons/org.nixos.nix-daemon.plist'
```

## Update flakes
Update **in the consumer**. Its lock decides what gets built, for every input including the ones this repo declares, so this is the only update that changes what your machine runs.

Everything:

```sh
cd ~/Documents/nix-home
nix flake update
```

A single input:

```sh
cd ~/Documents/nix-home
nix flake update nixpkgs
```

Then `hmSwitch` to build and activate.

Updating **in this repo** never changes what a machine runs. Its lock is only a seed: for a brand-new consumer's first build, and for the pins `--override-input` testing resolves against. So run it here only to stop local tests drifting behind what the consumer actually uses, or before setting up a new machine.

```sh
cd ~/Documents/nix-home/home-flake
nix flake update
```

When *adding* an input, use `nix flake lock` instead — it fills in missing entries without bumping anything that is already pinned.

## GitHub API rate limit
`github:` inputs resolve their revision through `api.github.com`, which allows 60 requests/hour for unauthenticated requests, counted per IP -- so on a shared office address it runs out. Nix then warns and falls back to its last cached lookup, which is *not* the same as leaving the lock alone: the cached revision can be newer than the pin.

An unscoped personal access token lifts that to 5000/hour. It must not go in `nix.settings`, because everything there lands in the world-readable `/nix/store`; `modules/nixBase.nix` instead points nix at a machine-local file that is never committed:

```sh
install -m600 /dev/null ~/.config/nix/tokens.conf
echo 'access-tokens = github.com=<token>' > ~/.config/nix/tokens.conf
```

Machines without that file are unaffected -- the include is prefixed with `!`, which makes a missing file non-fatal.

## Run `nix-tree`
Handy to see sizes etc.

For some reason have to type `nix-tree` again after starting `nix-shell`:
```sh
nix-shell -p nix-tree
```
On one installation there's a weird error message with that, use this instead:
```sh
nix run nixpkgs#nix-tree
```

## Home-manager generations
Lists all previous result folders, for easy activation of an earlier version.
```sh
home-manager generations
```

## Garbage collection
See also [Garbage Collection in Nix Reference Manual](https://nixos.org/manual/nix/unstable/package-management/garbage-collection.html).

To delete all old (non-current) generations of your current profile:

	nix-env --delete-generations old

After removing appropriate old generations you can run the garbage collector as follows:

	nix-store --gc
