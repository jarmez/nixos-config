# configuration.nix: Core system config. Best practices: Declarative, minimal, secure.
{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    inputs.hyprland.nixosModules.default  # Hyprland module import (inline config below).
    inputs.nixos-cosmic.nixosModules.default  # Cosmic module import (inline below).
  ];

  # Boot: systemd-boot with Secure Boot via Lanzaboote.
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = lib.mkForce false;  # Override for Lanzaboote.
    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";  # Generate keys during install (see script).
    };
  };
  boot.initrd = {
    systemd.enable = true;  # For TPM/FIDO2 in initrd.
    luks.devices."enc" = {
      device = "/dev/nvme0n1p2";  # Root partition. Placeholder: Adjust if needed.
      crypttabExtraOpts = [ "tpm2-device=auto" "fido2-device=auto" ];  # TPM first, FIDO2 fallback.
    };
  };
  boot.kernelParams = [ "amd_pstate=active" "resume=/dev/mapper/swap" ];  # Battery/perf, hibernation.
  boot.resumeDevice = "/dev/mapper/swap";  # Hibernation support.

  # Networking/Hostname.
  networking.hostName = "yoga-nix";
  networking.networkmanager.enable = true;  # WiFi/BT management.

  # Time/Locale.
  time.timeZone = "America/New_York";  # Placeholder: Edit to your zone (e.g., via `timedatectl` post-install).
  i18n.defaultLocale = "en_US.UTF-8";

  # Security.
  security.apparmor.enable = true;  # Preferred over SELinux for NixOS (path-based, low overhead).
  security.sudo.wheelNeedsPassword = false;  # For dev convenience; harden if needed.
  boot.kernel.sysctl."kernel.unprivileged_bpf_disabled" = 1;  # Restrict eBPF for security.

  # Users.
  users.users.james = {
    isNormalUser = true;
    description = "James Day";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "lp" ];  # Admin, BT/printing.
    shell = pkgs.zsh;  # Modern shell; configure via Home Manager.
    hashedPassword = "$y$j9T$...";  # Placeholder: Generate with `mkpasswd -m yescrypt` during install.
  };

  # Services.
  services = {
    xserver.enable = false;  # Wayland-only.
    greetd = {
      enable = true;
      settings.default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember --time --asterisks --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
        user = "greeter";
      };
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;  # AMD sound optimization: Dynamic profiles.
    };
    bluetooth.enable = true;  # BlueZ for devices.
    printing.enable = true;  # CUPS for printers.
    thermald.enable = true;  # Thermal management for Ryzen.
    auto-cpufreq = {
      enable = true;
      settings = {
        governor = "powersave";  # Battery focus.
        turbo = "auto";
      };
    };
    logind = {
      lidSwitch = "hibernate";  # Hibernation on lid close.
      extraConfig = "HandlePowerKey=hibernate";
    };
  };

  # Hardware/Graphics.
  hardware = {
    graphics.enable = true;  # AMD integrated.
    bluetooth.powerOnBoot = false;  # Save battery.
  };

  # Virtualization/Dev.
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;  # For DevPod/BoxBuddy.
  };

  # Packages.
  environment.systemPackages = with pkgs; [
    vim  # Fallback editor.
    git  # For flakes.
    curl
    wget
    systemd-cryptenroll  # For TPM/FIDO2.
    # Dev tools: Add more via Home Manager.
  ];

  # Fonts/HiDPI.
  fonts.enableDefaultPackages = true;
  services.xserver.videoDrivers = [ "amdgpu" ];  # Though Wayland.

  # Hyprland WM: Inline config (tiling for productivity; trends: Direct import for AMD stability).
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";  # AMD Wayland fix.
    QT_SCALE_FACTOR = "2";  # HiDPI.
  };

  # Cosmic DE: Inline config (beta tiling hybrid; 2025 trends: Rust efficiency on Ryzen).
  services.desktopManager.cosmic.enable = true;
  environment.variables = { COSMIC_SCALE = "2"; };  # HiDPI.
  environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = "1";  # Security: Clipboard control.

  # Nix settings.
  nix = {
    settings.auto-optimise-store = true;
    gc = { automatic = true; dates = "weekly"; };
    extraOptions = "experimental-features = nix-command flakes";
  };

  system.stateVersion = "25.11";  # Update on upgrades.
}
