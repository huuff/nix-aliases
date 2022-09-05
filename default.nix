{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.shell;
in {
  options.programs.shell = with types; {
    aliases = mkOption {
      type = attrsOf str;
      default = {};
      description = "Shell aliases to activate for all enabled shells";
    }; 

    scriptDir = mkOption {
      type = nullOr (either str path);
      default = null;
      description = "Directory where you hold your scripts, so it gets added to the $PATH";
    };
  };

  # TODO: Maybe my PATH addition syntax is not ok for all shells?
  # TODO: Make a lib to automate creating this structure, it'll be nice for implementing, for example, thefuck
  config = mkMerge [
    (mkIf (config.programs.bash.enable) {
      programs.bash = {
        shellAliases = cfg.aliases;

        initExtra = mkIf (cfg.scriptDir != null) ''
          PATH="$PATH:${toString cfg.scriptDir}"
        '';
      };
    })

    (mkIf (config.programs.fish.enable) {
      programs.fish = {
        shellAliases = cfg.aliases;

        initExtra = mkIf (cfg.scriptDir != null) ''
          PATH="$PATH:${toString cfg.scriptDir}"
        '';
      };
    })

    (mkIf (config.programs.zsh.enable) {
      programs.zsh = {
        shellAliases = cfg.aliases;
      };

        initExtra = mkIf (cfg.scriptDir != null) ''
          PATH="$PATH:${toString cfg.scriptDir}"
        '';
    })
  ];
}
