{
  description = "GoogleCloudPlatform/govanityurls on NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        version = "0.1.0";
      in {
        packages.govanityurls = pkgs.buildGoModule {
          pname = "govanityurls";
          inherit version;

          src = pkgs.fetchFromGitHub {
            owner = "GoogleCloudPlatform";
            repo = "govanityurls";
            rev = "v${version}";
            sha256 = "09fc0086mkj62qkv0mpybqg0yby179wm1fgx82f8sb3mmpi1ccch";
          };

          goPackagePath = "github.com/GoogleCloudPlatform/govanityurls";
          vendorHash = null;
        };
      }
    )
    // {
      nixosModules.govanityurls = {
        config,
        lib,
        pkgs,
        ...
      }:
        with lib; let
          cfg = config.services.govanityurls;
          settingsFormat = pkgs.formats.yaml {};
          configFile = settingsFormat.generate "vanity.yaml" cfg.settings;
        in {
          options.services.govanityurls = {
            enable = mkEnableOption "govanityurls service";

            package = mkOption {
              type = types.package;
              default = self.packages.${pkgs.system}.govanityurls;
              description = "govanityurls package to use.";
            };

            port = mkOption {
              type = types.port;
              default = 8080;
              description = "Port on which the govanityurls service listens.";
            };

            settings = lib.mkOption {
              type = settingsFormat.type;
              default = {};
              description = ''
                Configuration for the govanityurls service.

                See [govanityurls README](https://github.com/GoogleCloudPlatform/govanityurls/tree/v${cfg.package.version}?tab=readme-ov-file#configuration-file) for supported settings.
              '';
            };
          };

          config = mkIf cfg.enable {
            systemd.services.govanityurls = {
              description = "govanityurls service";
              wantedBy = ["multi-user.target"];
              after = ["network.target"];
              serviceConfig = {
                ExecStart = "${cfg.package}/bin/govanityurls ${configFile}";
                Environment = "PORT=${toString cfg.port}";
                DynamicUser = true;
                NoNewPrivileges = true;
              };
            };
          };
        };
    };
}
