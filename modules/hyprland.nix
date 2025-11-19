# hyprland.nix: Hyprland WM config. Tiling for productivity.
{ pkgs, inputs, ... }:

{
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";  # AMD Wayland fix.
    QT_SCALE_FACTOR = "2";  # HiDPI.
  };
  # Add Hyprland session.
}
