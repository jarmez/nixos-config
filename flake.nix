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
    nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic";  # Correct flake for Cosmic DE (beta/nightly).
    nixpkgs.follows = "nixos-cosmic/nixpkgs";  # Sync with Cosmic's unstable for compatibility.
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, lanzaboote, hyprland, nixos-cosmic, ... }@inputs:
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
          nixos-cosmic.nixosModules.default  # Import Cosmic module.
          { 
            home-manager.useGlobalPkgs = true; 
            home-manager.useUserPackages = true; 
            home-manager.users.james = import ./home.nix;  # System-wide Home Manager for declarative user config.
            nix.settings = {
              substituters = [ "https://cosmic.cachix.org/" "https://hyprland.cachix.org" ];  # Caches for faster builds (trends: Essential for Rust/Wayland on laptops).
              trusted-public-keys = [ 
                "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" 
                "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" 
              ];
            };
          }
        ];
      };
    };
}
