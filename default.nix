{ config, lib, pkgs, ... }:

with lib;
with types;

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
  options.programs.shell = {
    aliases = mkOption {
      type = attrsOf str;
      default = {};
      description = "Shell aliases to activate for all enabled shells";
    }; 

    scriptDir = mkOption {
      type = nullOr (oneOf [str path]);
      default = null;
      description = "Directory where you hold your scripts, so it gets added to the $PATH";
    };

    # TODO: Accept a derivation?
    completionsDir = mkOption {
      type = shellDiscriminatedModule (oneOf [str path]);
      default = null;
      description = "Directories where your completion scripts lie";
    };
  };

  # TODO: Make a lib to automate creating this structure, it'll be nice for implementing, for example, thefuck
  config = mkMerge [
    (mkIf (config.programs.bash.enable) {
      programs.bash = {
        shellAliases = cfg.aliases;

        initExtra = (concatStringsSep "\n" [
          (optionalString (cfg.scriptDir != null) ''PATH="$PATH:${cfg.scriptDir}"'')
          (optionalString (cfg.completionsDir.bash != null) ''
            for compfile in ${cfg.completionsDir.bash}/*; do
              [ -f "$compfile" ] && source "$compfile"
            done
          '')
        ]);
      };
    })

    (mkIf (config.programs.fish.enable) {
      programs.fish = {
        shellAliases = cfg.aliases;

        shellInit = (concatStringsSep "\n" [
          (optionalString (cfg.scriptDir != null) ''fish_add_path "${cfg.scriptDir}"'')
          (optionalString (cfg.completionsDir.fish != null) ''set -p fish_complete_path "${cfg.completionsDir.fish}"'')
        ]);
      };

      home.file.".config/fish/completions" = mkIf (cfg.completionsDir.fish != null) {
         source = config.lib.file.mkOutOfStoreSymlink cfg.completionsDir.fish;
      };
    })

    (mkIf (config.programs.zsh.enable) {
      programs.zsh = {
        shellAliases = cfg.aliases;

        initExtra = (concatStringsSep "\n" [
            (optionalString (cfg.scriptDir != null) ''PATH="$PATH:${cfg.scriptDir}"'')
            (optionalString (cfg.completionsDir.zsh != null) ''fpath=("${cfg.completionsDir.zsh}" $fpath)'')
        ]);
      };
    })
  ];
}
