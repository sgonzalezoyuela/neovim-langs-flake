{
  description = "Typescript/HTML neovim";
  inputs = {
    neovim-flake.url = "github:jordanisaacs/neovim-flake";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    neovim-flake,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (nixpkgs) lib;
        baseNeovim = neovim-flake.packages.${system}.nix;
        nvimBin = pkg: "${pkg.bin}/nvim";

        # Typescript
        tsCfg = {
          #config.vim.theme.name = "dracula-nvim";
          config.vim.languages.nix.enable = false;
          config.vim.languages.ts.enable = true;
          config.vim.languages.html.enable = true;
          config.vim.languages.sql.enable = true;
        };

        ts.neovim-ts = baseNeovim.extendConfiguration {
          modules = [tsCfg];
          inherit pkgs;
        };

        # Golang
        goCfg = {
          #config.vim.theme.name = "dracula-nvim";
          config.vim.languages.nix.enable = false;
          config.vim.languages.go.enable = true;
        };

        go.neovim-go = baseNeovim.extendConfiguration {
          modules = [goCfg];
          inherit pkgs;
        };
      in {
        packages = rec {
          inherit (ts) neovim-ts;
          inherit (go) neovim-go;
          default = neovim-ts;
        };
        apps = rec {
          ts = {
            type = "app";
            program = nvimBin ts.neovim-ts;
          };
          go = {
            type = "app";
            program = nvimBin go.neovim-go;
          };
          default = ts;
        };
      }
    );
}
