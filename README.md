# govanityurls-flake

A Nix Flake for [GoogleCloudPlatform/govanityurls](https://github.com/GoogleCloudPlatform/govanityurls). It provides:

- `packages.govanityurls`: the `govanityurls` binary.
- `nixosModules.govanityurls`: a NixOS module that starts `govanityurls` as a systemd service.

## Example Usage

```nix

services.govanityurls = {
    enable = true;
    settings = {
        host = "go.zidhuss.tech";
        paths = {
            "/example" = {
                repo = "https://github.com/zidhuss/example";
            };
        };
    };
};
```
