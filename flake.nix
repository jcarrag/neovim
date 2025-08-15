{
  description = "my neovim config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        packages.neovim = pkgs.callPackage ./neovim.nix { };
        packages.default = self.packages.${system}.neovim;
        apps.neovim = flake-utils.lib.mkApp {
          drv = self.packages.${system}.neovim;
          name = "neovim";
          exePath = "/bin/nvim";
        };
        apps.default = self.apps.${system}.neovim;
      }
    );
}
