{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nix;
  dir = config.nix.hmConfigDir;
  baseFlake = config.nix.hmBaseFlake;

  aliases =
    optionalAttrs (dir != null) {
      # flake based home manager utilities
      hmCd = "cd ${dir}";
      hmBuild = "hmCd && nix build .";
      hmActivate = "hmCd && ./result/activate && source ~/.config/fish/config.fish";
      hmSwitch = "hmBuild && hmActivate";
    }
    // optionalAttrs (baseFlake != null) {
      # assuming a home-flake setup
      hmPull = "hmCd && nix flake update ${baseFlake}";
      hmPullBuild = "hmPull && hmBuild";
      hmPullSwitch = "hmPullBuild && hmActivate";
      hmLocalBuild = "hmCd && nix build . --override-input ${baseFlake} ./${baseFlake}";
      hmLocalSwitch = "hmLocalBuild && hmActivate";
    };
  homePrefixDefault =
    if (builtins.match ".*-darwin" pkgs.stdenv.hostPlatform.system != null)
    then "/Users"
    else "/home";
in {
  options.nix = {
    hmConfigDir = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Location of the home manager flake";
    };
    hmBaseFlake = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Name of a base flake";
    };
    experimentalFeatures = mkOption {
      type = types.nullOr types.str;
      default = "nix-command flakes";
      description = "Enabling experimental features";
    };
    hmHomePrefix = mkOption {
      type = types.nullOr types.str;
      default = homePrefixDefault;
      description = "set homeDirectory to /home/{username} (linux) or /Users/{username} (darwin)";
    };
  };
  config.home.homeDirectory = mkIf (cfg.hmHomePrefix != null) "${config.nix.hmHomePrefix}/${config.home.username}";
  config.programs.home-manager.enable = cfg.hmConfigDir != null;
  config.home.packages = [pkgs.nix];
  config.nix = {
    package = pkgs.nix;
    settings = optionalAttrs (cfg.experimentalFeatures != null) {
      experimental-features = cfg.experimentalFeatures;
    };
    # Machine-local secrets, e.g. `access-tokens = github.com=<token>`. The
    # leading `!` makes the file optional, so machines without one still
    # evaluate. Never put the token itself in nix.settings: everything there
    # lands in the world-readable /nix/store.
    extraOptions = ''
      !include ${config.home.homeDirectory}/.config/nix/tokens.conf
    '';
  };
  config.programs.fish.shellAliases = aliases; # optionalAttrs (cfg.hmConfigDir != null) aliases;
  config.home.stateVersion = "22.11"; # override with 'home.stateVersion = lib.mkForce "22.05";'
}
