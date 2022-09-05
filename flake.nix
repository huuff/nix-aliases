{
  description = "Home Manager module that takes shell-independent configuration and applies it to all enabled shells (bash, zsh, fish)";

  # TODO: Is it necessary? I don't think I use any package
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
  };

  outputs = { self, nixpkgs }: {
    nixosModules.shell = import ./default.nix; 
  };
}
