# home.nix: User config via Home Manager. Place in /home/james/.config/home-manager/home.nix; activate with `home-manager switch`.
{ pkgs, ... }:

{
  home.username = "james";
  home.homeDirectory = "/home/james";

  # Packages.
  home.packages = with pkgs; [
    firefox librewolf google-chrome  # Browsers.
    neovim  # Editor; configure plugins via lua.
    vlc spotify  # Media.
    devpod boxbuddy  # Podman tools.
    # Add more: e.g., rustup, python.
  ];

  # Neovim basic config (expand with plugins).
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Zsh (shell).
  programs.zsh.enable = true;

  # Hyprland user config (e.g., ~/.config/hypr/hyprland.conf).
  # Placeholder: Copy defaults and tweak (keybinds, monitors scaling=2).

  home.stateVersion = "25.11";
}
