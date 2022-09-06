{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.shell;
  shellDiscriminatedModule = type: submodule {
    options = {
      bash = mkOption {
        type = nullOr type;
        description = "bash value for this specific configuration";
        default = null;
      };
      zsh = mkOption {
        type = nullOr type;
        description = "zsh value for this specific configuration";
        default = null;
      };
      fish = mkOption {
        type = nullOr type;
        description = "fish value for this specific configuratioN";
        default = null;
      };
    };
  };
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

    completionsDir = mkOption {
      type = nullOr shellDiscriminatedModule;
      default = null;
      description = "Directories where your completion scripts lie";
    };
  };

  # TODO: Make a lib to automate creating this structure, it'll be nice for implementing, for example, thefuck
  config = mkMerge [
    (mkIf (config.programs.bash.enable) {
      programs.bash = {
        shellAliases = cfg.aliases;

        initExtra = mkIf (cfg.scriptDir != null) ''
          PATH="$PATH:${toString cfg.scriptDir}"
        '';
      };

      home.file.".local/share/bash_completion".target = mkIf (cfg ? completionsDir && cfg.completionsDir ? bash) cfg.completionsDir.bash;
    })

    (mkIf (config.programs.fish.enable) {
      programs.fish = {
        shellAliases = cfg.aliases;

        shellInit = mkIf (cfg.scriptDir != null) ''
          fish_add_path ${toString cfg.scriptDir}

        '';
      };
    })

    (mkIf (config.programs.zsh.enable) {
      programs.zsh = {
        shellAliases = cfg.aliases;

        initExtra = mkIf (cfg.scriptDir != null) ''
          PATH="$PATH:${toString cfg.scriptDir}"
        '';
      };

    })
  ];
}
