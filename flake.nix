{
  inputs.neovim-flake.url = "github:jordanisaacs/neovim-flake";

  outputs = {
    nixpkgs,
    neovim-flake,
    ...
  }: let
    # TODO : Support other systems!
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    inherit (nixpkgs) lib;

    # Base config for all outputs
    configModule = {
      config.vim = {
        theme.name = "dracula-nvim";
        languages = {
          nix.enable = lib.mkForce true;
          bash.enable = lib.mkForce true;
          terraform.enable = lib.mkForce true;
          markdown.enable = lib.mkForce true;
          enableDebugger = lib.mkForce true;
        };
        filetree.nvimTreeLua = {
          enable = true;
          treeWidth = 25;
          resizeOnFileOpen = true;
        };
      };
    };

    # Web development config
    configWeb = {
      config = {
        vim = {
          theme.name = lib.mkForce "catppuccin";
          languages = {
            ts.enable = lib.mkForce true;
            html.enable = lib.mkForce true;
            markdown.enable = lib.mkForce true;
          };
        };
      };
    };

    configGo = {
      config = {
        vim = {
          #theme.name = lib.mkForce "catppuccin";
          languages = {
            go.enable = lib.mkForce true;
            markdown.enable = lib.mkForce true;
          };
        };
      };
    };

    configRs = {
      config = {
        vim = {
          #theme.name = lib.mkForce "catppuccin";
          languages = {
            rust.enable = lib.mkForce true;
            markdown.enable = lib.mkForce true;
          };
        };
      };
    };

    configPy = {
      config = {
        vim = {
          #theme.name = lib.mkForce "catppuccin";
          languages = {
            python.enable = lib.mkForce true;
            bash.enable = lib.mkForce true;
            markdown.enable = lib.mkForce true;
          };
        };
      };
    };

    baseNeovim = neovim-flake.packages.${system}.nix;
    neovimBase = baseNeovim.extendConfiguration {
      modules = [configModule];
      inherit pkgs;
    };
    neovimWeb = baseNeovim.extendConfiguration {
      modules = [configModule configWeb];
      inherit pkgs;
    };
    neovimGo = baseNeovim.extendConfiguration {
      modules = [configModule configGo];
      inherit pkgs;
    };
    neovimRs = baseNeovim.extendConfiguration {
      modules = [configModule configRs];
      inherit pkgs;
    };
    neovimPy = baseNeovim.extendConfiguration {
      modules = [configModule configPy];
      inherit pkgs;
    };
  in {
    packages.${system} = {
      default = neovimBase;
      neovim = neovimBase;
      neovim-web = neovimWeb;
      neovim-go = neovimGo;
      neovim-rs = neovimRs;
      neovim-py = neovimPy;
    };
  };
}
