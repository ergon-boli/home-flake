# home-flake
A nix home-manager flake to set up my stuff

Build and activate with
```sh
cd into/this/repo/
nix build
result/activate
```

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
