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

  # Alternative URLs (mirrors) for the nix-litex repository are
  #
  # - https://github.com/lschuermann/nix-litex.git
  # - https://git.currently.online/leons/nix-litex.git
  #
  nixLitexSrc = builtins.fetchGit {
    # Temporary downtime of git.sr.ht, see
    # https://status.sr.ht/issues/2023-01-10-network-outage/
    #url = "https://git.sr.ht/~lschuermann/nix-litex";
    url = "https://git.currently.online/leons/nix-litex.git";
    ref = "main";
    rev = "75fb0a2b9be43f43b8b14a2f0fd437ebdd8ba76f";
  };

  litexPackages = import "${nixLitexSrc}/pkgs" {
    inherit pkgs;
    skipChecks = skipLitexPkgChecks;
  };

  lschuermannNurPkgs = import (builtins.fetchGit {
    url = "https://github.com/lschuermann/nur-packages.git";
    ref = "master";
    rev = "dfc0d0e5f22f6dcc5bfc843193f6390c5e8d079b";
  }) { inherit pkgs; };

  vivado = lschuermannNurPkgs.vivado-2022_2;

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
        # Override the CPU to add the TockSecureIMC variant patch:
        pythondata-cpu-vexriscv = (upstream.pythondata-cpu-vexriscv.override ({
          generated = upstream.pythondata-cpu-vexriscv.generated.overrideAttrs (prev: {
            # This patched revision is based on the upstream pythondata-cpu-vexriscv
            # revision `3b8d17ee104b07113ff0889e72d5a6d5a5610c2d`, which is targete
            # by the referenced nix-litex upstream. Thus the scala packages should
            # be compatible, and we can simply override the source attribute.
            src = builtins.fetchGit {
              url = "https://github.com/lschuermann/litex-vexriscv-custom";
              ref = "refs/heads/cibranch0";
              rev = "38883a2be5587bf8556d71503386d8afe970a54b";
              submodules = true;
            };
          });
        }));

        # Override LiteX to include support for the TockSecureIMC
        # CPU variant:
        litex-unchecked = upstream.litex-unchecked.overrideAttrs (prev: {
          patches = (prev.patches or [ ]) ++ [
            ./litex_add_TockSecureIMC_CPU.patch
            ./litex_disable_TFTP_block_size_negotiation.patch
          ];
        });

        litex-boards-unchecked = upstream.litex-boards-unchecked.overrideAttrs (prev: {
          # Unfortunately, the upstream nix-litex overrides the
          # patchPhase for litex-boards, which prevents us from
          # specifying patches here. In the meantime, apply the patch
          # manually:
          patchPhase = ''
            patch -p1 <${./litex-boards_targets-arty-add-option-to-set-with_buttons.patch}
          '' + (prev.patchPhase or "");
        });
      };

  applyOverlay = python: python.override {
    packageOverrides = customizedPythonOverlay;
  };

  overlay = self: super: {
    mkSbtDerivation = litexPackages.mkSbtDerivation;
  } // (litexPackages.applyPythonOverlays super applyOverlay);

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
