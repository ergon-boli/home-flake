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
```sh
zsh # if fish is active

curl -L https://nixos.org/nix/install -o install.sh
sh install.sh --darwin-use-unencrypted-nix-store-volume

# reboot # no longer necessary?
```

## add flake support
```sh
zsh # if fish is active

# nix-env -iA nixpkgs.nixFlakes
mkdir -p ~/.config/nix 
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
```

## install home-manager
This whole section is not needed
```sh
zsh # if fish is active
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --add https://github.com/LnL7/nix-darwin/archive/master.tar.gz darwin
nix-channel --update
export NIX_PATH=darwin-config=$HOME/.nixpkgs/darwin-configuration.nix:$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
nix-shell '<home-manager>' -A install
```

## install my stuff
```sh
cd ~/Documents/nix-home
git clone git@github.com:shrugalic/home-flake.git
cp home-flake/template/flake.nix .
# edit flake.nix as needed
nix build
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

