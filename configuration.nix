flakes:
{ config, lib, pkgs, ... }:
with lib;
{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages =
    [
    ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix = {
    package = pkgs.nixUnstable;
    # useSandbox = true;
    registry = {
      templates = {
        from = {
          id = "templates";
          type = "indirect";
        };
        to = {
          owner = "winterqt";
          repo = "templates";
          type = "github";
        };
      };
    };
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-derivations = true
      keep-outputs = true
    '';
    nixPath = { nixpkgs = flakes.nixpkgs; };
  };
  nixpkgs.config.allowUnfree = true;

  programs.fish = {
    enable = true;
    useBabelfish = true;
    babelfishPackage = pkgs.babelfish;
  };

  # path trickery, see https://github.com/LnL7/nix-darwin/issues/122
  environment.etc."paths" = {
    text = concatStringsSep "\n" ([ "/Users/winter/.nix-profile/bin" ] ++ (remove "$HOME/.nix-profile/bin" (splitString ":" config.environment.systemPath)));
    knownSha256Hashes = [
      "cdfc5a48233b2f44bc18da0cf5e26df47e9424820793d53886aa175dfbca7896"
    ];
  };

  users.users.winter = {
    name = "winter";
    home = "/Users/winter";
  };

  system.activationScripts.postActivation.text = ''
    dscl . -create '/Users/winter' UserShell '${pkgs.fish}/bin/fish'
  '';

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
