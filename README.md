# home-flake
A nix home-manager flake to set up my stuff

Build and activate with
```sh
cd into/this/repo/
nix build
result/activate
```

## Test local changes before publishing

The consumer flake (`template/flake.nix`, i.e. the `flake.nix` one directory up)
pulls this repo from GitHub, so it normally only sees changes that have been
pushed. To try out a local working copy first, override the input:

```sh
cd ~/Documents/nix-home
nix build --override-input home-flake path:$PWD/home-flake
result/activate
```

Notes:
- `path:` copies the working tree as-is, so **uncommitted and untracked** changes
  are included. (`git+file://` would only see committed content.)
- The override is not written to `flake.lock` — Nix prints
  `warning: not writing modified lock file`. Once you're happy, commit, push and
  run a normal `nix flake update` to pin the real revision.
- Check what actually got built before activating, e.g.
  `cat result/home-files/.config/hunk/config.toml`.
- Overriding forces a re-lock of this flake's own inputs, so you may see
  `HTTP error 403 ... API rate limit exceeded ...; using cached version` for the
  remaining `github:` inputs. That's a **warning**, not an error — Nix falls back
  to the locked revision, which is what you wanted anyway. Only worry if the repo
  named in the warning is one whose HEAD you actually needed to move.

----

# Step by step Nix install

## install nix
According to [the documentation](https://nixos.org/download/).

## install my stuff initially
```sh
cd ~/Documents/nix-home
git clone git@github.com:ergon-boli/home-flake.git
cp home-flake/template/flake.nix .
# edit flake.nix as needed
/nix/var/nix/profiles/default/bin/nix build --extra-experimental-features nix-command --extra-experimental-features flakes
result/activate
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
Everything:
```sh
nix flake update
```

Specific thing:
```sh
nix flake lock --update-input nixpkgs
```

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
