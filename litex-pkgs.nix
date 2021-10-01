{ pkgs ? (import <nixpkgs> {})
, # Given we inject a custom nix-litex pkgMetas TOML file, we'll want
  # to -- by default -- make sure the result is properly tested
  skipLitexPkgChecks ? false
, ... }:

let
  # Use builtins.fromTOML if available, otherwise use remarshal to
  # generate JSON which can be read. Code taken from
  # nixpkgs/pkgs/development/tools/poetry2nix/poetry2nix/lib.nix.
  fromTOML = pkgs: builtins.fromTOML or (
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

  # Definition of the LiteX packages and associated versions and
  # hashes. This format is defined by
  # [nix-litex](https://git.sr.ht/~lschuermann/nix-litex).
  pkgMetas = fromTOML pkgs (builtins.readFile ./litex-pkgs.toml);

  # Alternative URLs (mirrors) for the nix-litex repository are
  #
  # - https://github.com/lschuermann/nix-litex.git
  #
  nixLitexSrc = builtins.fetchGit {
    url = "https://git.sr.ht/~lschuermann/nix-litex";
    ref = "main";
    rev = "24060aa33f38d619992806851d048d15f3a56546";
  };

  litexPackages = import "${nixLitexSrc}/pkgs" {
    inherit pkgs pkgMetas;
    skipChecks = skipLitexPkgChecks;
  };

  vivado = pkgs.callPackage "${nixLitexSrc}/pkgs/vivado" { };

  # There are some packages which need to be customized here. However
  # we still want to benefit from all the testing infrastructure of
  # the nix-litex repository. Thus we override the pythonOverlay and
  # inject our own package definitions.
  customizedPythonOverlay = self: super:
    let
      # First, call the original overlay
      upstream = litexPackages.pythonOverlay self super;
    in
      # Now, inject our custom packages in the resulting attribute set
      upstream // {
        pythondata-cpu-vexriscv = self.callPackage (
          import ./pythondata-cpu-vexriscv.nix pkgMetas.pythondata-cpu-vexriscv
        ) { };
      };

  applyOverlay = python: python.override {
    packageOverrides = customizedPythonOverlay;
  };

  overlay = self: super: {
    python3 = applyOverlay super.python3;
    python37 = applyOverlay super.python37;
    python38 = applyOverlay super.python38;
    python39 = applyOverlay super.python39;
    python310 = applyOverlay super.python310;
  };

  extended = pkgs.extend overlay;

  pkgSet =
    (builtins.foldl'
      (acc: elem: acc // {
        ${elem} = extended.python3Packages.${elem};
      })
      { }
      (builtins.attrNames litexPackages.packages)
    ) // {
      # Maintenance scripts for working with the TOML files in this repo
      maintenance = litexPackages.maintenance;

      # Vivado derivation, useful for builting the bitstreams for some
      # of the boards defined in this repo.
      inherit vivado;
    };


in
  pkgSet
