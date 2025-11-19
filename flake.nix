# flake.nix: Entry point for the configuration. Enables flakes, Home Manager, and external modules.
# Run `nix flake update` to lock dependencies. Build with `nixos-rebuild switch --flake .#jd-nix`.
{
  description = "NixOS config for yoga-nix laptop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";  # Latest for WiFi 7/AMD support
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-cosmic, hyprland, ... }@inputs: {
    nixosConfigurations.jd-nix = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/jd-nix/configuration.nix  # System config
        home-manager.nixosModules.home-manager  # Integrate Home Manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.james = import ./home/james.nix;  # User config
          };
        }
        nixos-cosmic.nixosModules.default  # Cosmic DE module
        hyprland.nixosModules.default  # Hyprland module
      ];
    };
  };
}
