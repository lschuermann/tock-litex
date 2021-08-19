{ pkgs }:

let
  # Use builtins.fromTOML if available, otherwise use remarshal to
  # generate JSON which can be read. Code taken from
  # nixpkgs/pkgs/development/tools/poetry2nix/poetry2nix/lib.nix.
  fromTOML = builtins.fromTOML or (
    toml: builtins.fromJSON (
      builtins.readFile (
        pkgs.runCommand "from-toml"
          {
            inherit toml;
            allowSubstitutes = false;
            preferLocalBuild = true;
          }
          ''
            ${pkgs.remarshal}/bin/remarshal \
              -if toml \
              -i <(echo "$toml") \
              -of json \
              -o $out
            ''
      )
    )
  );

  readTOML = path: fromTOML (builtins.readFile path);

  # Read the file containing the different LiteX and related packages'
  # versions. This is done to have a central place where versions can
  # be pinned, to allow users to choose between using a Nix derivation
  # or setting up a regular Python environment and manually collecting
  # the system dependencies.
  pkgMetas = readTOML ./litex_packages.toml;

in
  rec {
    migen = pkgs.callPackage (import ./migen.nix pkgMetas.migen) {};

    pythondata-cpu-vexriscv = pkgs.callPackage ./pythondata-cpu-vexriscv {};
    pythondata-software-compiler-rt = pkgs.callPackage (
      import ./pythondata-software-compiler-rt.nix pkgMetas.pythondata-software-compiler_rt) {};
    pythondata-misc-tapcfg = pkgs.callPackage (
      import ./pythondata-misc-tapcfg.nix pkgMetas.pythondata-misc-tapcfg) {};

    litex = pkgs.callPackage (
      import ./litex pkgMetas.litex
    ) {
      python3Packages = pkgs.python3Packages // {
        pythondata-software-compiler-rt = pythondata-software-compiler-rt;
        migen = migen;
      };
    };

    litex-boards = pkgs.callPackage (
      import ./litex-boards.nix pkgMetas.litex-boards
    ) {
      python3Packages = pkgs.python3Packages // {
        litex = litex;
      };
    };

    litedram = pkgs.callPackage (
      import ./litedram.nix pkgMetas.litedram
    ) {
      python3Packages = pkgs.python3Packages // {
        pythondata-software-compiler-rt = pythondata-software-compiler-rt;
        migen = migen;
        litex = litex;
      };
    };

    liteeth = pkgs.callPackage (
      import ./liteeth.nix pkgMetas.liteeth
    ) {
      python3Packages = pkgs.python3Packages // {
        litex = litex;
      };
    };

    litespi = pkgs.callPackage (
      import ./litespi.nix pkgMetas.litespi
    ) {
      python3Packages = pkgs.python3Packages // {
        litex = litex;
      };
    };


    liteiclink = pkgs.callPackage (
      import ./liteiclink.nix pkgMetas.liteiclink
    ) {
      python3Packages = pkgs.python3Packages // {
        litex = litex;
        migen = migen;
      };
    };

    litescope = pkgs.callPackage (
      import ./litescope.nix pkgMetas.litescope
    ) {
      python3Packages = pkgs.python3Packages // {
        litex = litex;
      };
    };

    litehyperbus = pkgs.callPackage (
      import ./litehyperbus.nix pkgMetas.litehyperbus
    ) {
      python3Packages = pkgs.python3Packages // {
        migen = migen;
        litex = litex;
      };
    };

    litepcie = pkgs.callPackage (
      import ./litepcie.nix pkgMetas.litepcie
    ) {
      python3Packages = pkgs.python3Packages // {
        migen = migen;
        litex = litex;
      };
    };
  }
