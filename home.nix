flakes:
{ config, lib, pkgs, ... }:

let secrets = import ./secrets.nix; in

{
  home.packages = with pkgs; [
    nixpkgs-fmt
    cargo-edit
    rustfmt
    mpv
    fd
    ripgrep
    ripgrep-all
    postgresql
    exa
    (flakes.newmail.packages.aarch64-darwin.newmail.override secrets.newmail)
    jq
    tokei
  ];
  # thanks, reckenrode! (https://github.com/nix-community/home-manager/issues/1341#issuecomment-882908749)
  home.activation = {
    copyApplications =
      let
        apps = pkgs.buildEnv {
          name = "home-manager-applications";
          paths = config.home.packages;
          pathsToLink = "/Applications";
        };
      in
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        appsSrc="${apps}/Applications/"
        baseDir="$HOME/Applications/Home Manager Apps"
        rsyncArgs="--archive --checksum --chmod=-w --copy-unsafe-links --delete"
        $DRY_RUN_CMD mkdir -p "$baseDir"
        $DRY_RUN_CMD ${pkgs.rsync}/bin/rsync ''${VERBOSE_ARG:+-v} $rsyncArgs "$appsSrc" "$baseDir"
      '';
  };
  programs.fish = {
    enable = true;
    plugins = [{
      name = "dracula";
      src = pkgs.fetchFromGitHub {
        owner = "dracula";
        repo = "fish";
        rev = "28db361b55bb49dbfd7a679ebec9140be8c2d593";
        sha256 = "07kz44ln75n4r04wyks1838nhmhr7jqmsc1rh7am7glq9ja9inmx";
      };
    }];
    shellAliases = { "vim" = "nvim"; "ls" = "exa"; };
  };
  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [ dracula-vim vim-nix ];
  };
  programs.git = {
    enable = true;
    userName = "Winter";
    userEmail = secrets.git.email;
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
  };
  programs.vscode = {
    enable = true;
    userSettings = {
      "update.mode" = "none";
      "telemetry.enableTelemetry" = false;
      "extensions.autoCheckUpdates" = false;
      "extensions.autoUpdate" = false;

      "workbench.colorTheme" = "Dracula";
      "editor.fontSize" = 14;
      "editor.fontFamily" = "JetBrains Mono";
      "editor.fontLigatures" = true;

      "editor.formatOnSave" = true;
      "files.insertFinalNewline" = true;

      "rust-analyzer.experimental.procAttrMacros" = true;
    };
    extensions = with pkgs.vscode-extensions; [
      dracula-theme.theme-dracula
      matklad.rust-analyzer
      tamasfe.even-better-toml
      jnoortheen.nix-ide
      (pkgs.callPackage
        ({ vscode-utils }: vscode-utils.buildVscodeMarketplaceExtension
          {
            mktplcRef = {
              name = "just";
              publisher = "skellock";
              version = "2.0.0";
              sha256 = "1ph869zl757a11f8iq643f79h8gry7650a9i03mlxyxlqmspzshl";
            };
          }
        )
        { })
    ];
  };
  home.sessionVariables = {
    SSH_AUTH_SOCK = "/Users/winter/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
    EDITOR = "nvim";
  };
  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
      enableFlakes = true;
    };
    stdlib = ''
      : ''${XDG_CACHE_HOME:=$HOME/.cache}
      declare -A direnv_layout_dirs
      direnv_layout_dir() {
          echo "''${direnv_layout_dirs[$PWD]:=$(
              echo -n "$XDG_CACHE_HOME"/direnv/layouts/
              echo -n "$PWD" | shasum | cut -d ' ' -f 1
          )}"
      }
    '';
  };
  home.stateVersion = "21.11";
}
