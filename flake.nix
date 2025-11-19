# flake.nix: Reproducible entry point. Lock with `nix flake lock`. Build with `nixos-rebuild switch --flake .#yoga-nix`.
{
  description = "NixOS config for yoga-nix laptop: Secure, efficient daily driver for dev/productivity/entertainment.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";  # Latest for Cosmic/Hyprland features (Nov 2025).
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";  # AMD Ryzen tweaks.
    lanzaboote.url = "github:nix-community/lanzaboote";  # Secure Boot integration.
    hyprland.url = "github:hyprwm/Hyprland";  # For Hyprland WM.
    cosmic.url = "github:System76/cosmic-nix";  # Alpha, track unstable.
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, lanzaboote, hyprland, cosmic, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };  # Unfree: Chrome, Spotify.
    in {
      nixosConfigurations.yoga-nix = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };  # Pass inputs to modules.
        modules = [
          ./configuration.nix
          ./hardware-configuration.nix
          home-manager.nixosModules.home-manager
          nixos-hardware.nixosModules.common-cpu-amd  # Ryzen AI 350 tweaks: P-state, graphics.
          nixos-hardware.nixosModules.common-gpu-amd
          lanzaboote.nixosModules.lanzaboote  # Secure Boot.
          { home-manager.useGlobalPkgs = true; home-manager.useUserPackages = true; }
        ];
      };
    };
}
