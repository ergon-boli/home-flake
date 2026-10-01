{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.sudoAskpass;
  askpass = pkgs.writeShellScript "sudo-askpass-1password" ''
    # sudo may run this with a PATH lacking Homebrew and the Nix profile
    PATH=/opt/homebrew/bin:${config.home.profileDirectory}/bin:$PATH
    exec op read ${escapeShellArg cfg.secretReference}
  '';
in {
  options.sudoAskpass.secretReference = mkOption {
    type = types.nullOr types.str;
    default = null;
    example = "op://Private/Mac login/password";
    description = ''
      1Password secret reference to this machine's login password. When set, `sudo` reads the
      password via `op`, which needs "Integrate with 1Password CLI" in the 1Password app's
      developer settings. Touch ID for sudo, where configured, is still tried first.
      `command sudo` bypasses 1Password, e.g. over ssh.
    '';
  };
  config = mkIf (cfg.secretReference != null) {
    home.sessionVariables.SUDO_ASKPASS = "${askpass}";
    programs.fish.shellAliases.sudo = "sudo -A";
  };
}
