{
  description = "Home Manager module that enables shell aliases for any shell that's enabled in Home Manager (bash, zsh, fish)";

  # TODO: Is it necessary? I don't think I use any package
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
  };

  outputs = { self, nixpkgs }: {
    nixosModules.aliases = import ./default.nix; 
  };
}
