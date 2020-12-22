let
  pinnedPkgs =
    import (builtins.fetchTarball {
      # Descriptive name to make the store path easier to identify
      name = "nixos-20.09-2020-12-22";
      # Commit hash for nixos-20.09 as of 2020-12-22
      url = "https://github.com/nixos/nixpkgs/archive/a3a3dda3bacf61e8a39258a0ed9c924eeca8e293.tar.gz";
      # Hash obtained using `nix-prefetch-url --unpack <url>`
      sha256 = "sha256:1ahn3srby9rjh7019b26n4rb4926di1lqdrclxfy2ff7nlf0yhd5";
    }) {};


  zipDeriv = name: deriv: pinnedPkgs.stdenv.mkDerivation {
    name = "${name}.zip";
    version = deriv.version;

    builder = pinnedPkgs.writeScript "build_${name}.zip.sh" ''
      #! ${pinnedPkgs.bash}/bin/bash

      if [ ! -d "${deriv}" ]; then
        echo "Derivation ${deriv} is not a directory"
        exit 1
      fi

      cd "${deriv}"
      ${pinnedPkgs.zip}/bin/zip -r "$out" .
    '';
  };

  socs = {
    "arty_a7-35t" = (import ./arty.nix) { pkgs = pinnedPkgs; };
  };

  lib = pinnedPkgs.lib;

in
  pinnedPkgs.linkFarm "tock-litex" (
    lib.mapAttrsToList (name: deriv: { name = "${name}.zip"; path = zipDeriv name deriv; }) socs
  )
