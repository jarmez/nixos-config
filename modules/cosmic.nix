# cosmic.nix: Cosmic DE (alpha). Emerging trend for Rust/Wayland efficiency.
{ pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    cosmic-applets cosmic-bg cosmic-comp cosmic-edit cosmic-files cosmic-greeter cosmic-icons cosmic-launcher cosmic-notifications cosmic-osd cosmic-panel cosmic-randr cosmic-screenshot cosmic-session cosmic-settings cosmic-settings-daemon cosmic-term cosmic-workspaces
  ];
  services.desktopManager.cosmic.enable = true;  # Session integration.
  environment.variables = { COSMIC_SCALE = "2"; };  # HiDPI.
}
