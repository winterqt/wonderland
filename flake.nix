{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.nix-darwin.url = "github:winterqt/nix-darwin";
  inputs.nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
  inputs.newmail.url = "github:winterqt/newmail";
  inputs.newmail.inputs.nixpkgs.follows = "nixpkgs";
  inputs.secrets.url = "path:/Users/winter/wonderland/secrets";
  inputs.secrets.flake = false;

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, ... }: {
    darwinConfigurations.snowball = nix-darwin.lib.darwinSystem {
      modules = [
        ((import ./configuration.nix) inputs)
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.users.winter = (import ./home.nix) inputs;
        }
      ];
      system = "aarch64-darwin";
    };
  };
}
