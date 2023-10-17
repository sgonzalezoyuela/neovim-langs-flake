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
        baseNeovim = neovim-flake.packages.${system}.nix;
        nvimBin = pkg: "${pkg}/bin/nvim";

        baseConfig = {
          config.vim = {
            theme.name = "dracula-nvim";
            statusline.lualine.theme = "dracula";
            filetree.nvimTreeLua = {
              enable = true;
              treeWidth = 25;
              resizeOnFileOpen = true;
            };
            languages = {
              nix.enable = true;
              bash.enable = true;
            };
          };
        };

        # Typescript
        tsCfg =
          {
            config.vim.languages = {
              #config.vim.theme.name = "dracula-nvim";
              ts.enable = true;
              html.enable = true;
            };
          }
          // baseConfig;

        tsPkg.neovim-ts = baseNeovim.extendConfiguration {
          modules = [tsCfg];
          inherit pkgs;
        };

        # Golang
        goCfg =
          {
            config.vim.languages = {
              #config.vim.theme.name = "dracula-nvim";
              go.enable = true;
            };
          }
          // baseConfig;

        goPkg.neovim-go = baseNeovim.extendConfiguration {
          modules = [goCfg];
          inherit pkgs;
        };
        # Nix (default)
        nixCfg =
          {
            #config.vim.theme.name = "dracula-nvim";
          }
          // baseConfig;

        nixPkg.neovim-nix = baseNeovim.extendConfiguration {
          modules = [nixCfg];
          inherit pkgs;
        };
      in {
        packages = rec {
          inherit (tsPkg) neovim-ts;
          inherit (goPkg) neovim-go;
          default = neovim-ts;
        };
        apps = rec {
          ts = {
            type = "app";
            program = nvimBin tsPkg.neovim-ts;
          };
          go = {
            type = "app";
            program = nvimBin goPkg.neovim-go;
          };
          nix = {
            type = "app";
            program = nvimBin nixPkg.neovim-nix;
          };
          default = nix;
        };
      }
    );
}
