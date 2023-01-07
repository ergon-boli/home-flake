{
  config,
  pkgs,
  lib,
  ...
}: {
  # Yabai: Tiling window management for the Mac
  # https://github.com/koekeishiya/yabai
  services = {
    nix-daemon.enable = true;
    yabai = {
      enable = true;
      package = pkgs.yabai;
      enableScriptingAddition = true;
      config = {
        layout = "bsp";
        auto_balance = "off"; # Auto balance makes it so all windows always occupy the same space, independent of how deeply nested they are in the window tree. When a new window is inserted or a window is removed, the split ratios will be automatically adjusted.
        split_ratio = "0.5"; # If auto balance is disabled, the split ratio defines how much space each window occupies after a new split is created.

        window_placement = "second_child"; # New windows spawn right/down
        window_topmost = "on"; # Make floating windows stay on top.
        window_origin_display = "default";
        window_shadow = "on"; # "float" Draw shadow for floating windows only
        window_animation_duration = "0.0"; # Duration of window frame animation

        top_padding = 1;
        bottom_padding = 1;
        left_padding = 1;
        right_padding = 1;
        window_gap = 1;

        active_window_opacity = "1.0"; # Opacity of the focused window
        normal_window_opacity = "0.95"; # Opacity of an unfocused window
        window_opacity_duration = "0.0"; # Duration of transition between active / normal opacity
        window_opacity = "off";

        insert_feedback_color = "0xffd75f5f";
        active_window_border_color = "0x8000D900";
        normal_window_border_color = "0x00555555";
        window_border_width = 1;
        window_border_radius = 12;
        window_border_blur = "off"; # Blur border allowing it to act as a backdrop for transparent windows
        window_border_hidpi = "on"; # Draw border in high resolution mode, for Retina displays
        window_border = "on";

        mouse_modifier = "ctrl";
        mouse_action1 = "move";
        mouse_action2 = "resize";
        mouse_follows_focus = "on";
        focus_follows_mouse = "off";
      };
      extraConfig = ''
        # Applications to not manage
        yabai -m rule --add app='System Settings' manage=off
        yabai -m rule --add app='Eclipse' manage=off
        yabai -m rule --add app='1Password' manage=off
        yabai -m rule --add app='LaunchBar' manage=off

        # Float the last space, which is the one on the secondary display
        yabai -m config --space last layout float
      '';
    };
    skhd = {
      enable = true;
      skhdConfig = builtins.readFile ./skhdrc;
    };
  };
}
