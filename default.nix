{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.aliases;
in {
  options.programs.aliases = with types; {
    aliases = mkOption {
      type = attrsOf str;
      default = {};
      description = "Shell aliases to activate for all enabled shells";
    }; 
  };

  config = {
    programs.bash.shellAliases = mkIf (config.programs.bash.enable) cfg.aliases;
    programs.fish.shellAliases = mkIf (config.programs.fish.enable) cfg.aliases;
    programs.zsh.shellAliases = mkIf (config.programs.zsh.enable) cfg.aliases;
  };

}
