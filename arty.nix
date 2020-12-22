# Nix expression to build LiteX for a Digilent Arty A7-35T board.
#
# This expression aims to generate a bitstream compatible with the
# [Tock litex/arty board
# definition](https://github.com/tock/tock/tree/master/boards/litex/arty).

{ pkgs ? (import <nixpkgs> {}) }:

with pkgs;

let
  litexPkgs = import ./pkgs { pkgs = pkgs; };

  # Avoid inclusion of modified version of
  # https://github.com/lukaslaobeyer/nix-fpgapkgs until it is assigned
  # a compatible license
  # (https://github.com/lukaslaobeyer/nix-fpgapkgs/issues/2)
  #
  # To build, override this with a path to a Vivado expression (the
  # binary should be located at "${vivado}/bin/vivado")
  #
  # The current releases are built with a Vivado version using the
  # system nixpkgs to avoid rebuilding the Vivado derivation. This
  # shouldn't be an issue given that the Vivado derivation is
  # currently not included within this repository and hence
  # (unfortunately) this has no chance of being reproducible anyways.
  #
  #vivado = (import <nixpkgs> {}).callPackage ./pkgs/vivado {};

in
  stdenv.mkDerivation {
    pname = "litex-arty";
    version = litexPkgs.litex.version;

    src = litexPkgs.litex.src;

    buildInputs = with pkgs; with litexPkgs; [
      python38

      litex litedram liteeth liteiclink
      pythondata-cpu-vexriscv

      pkgsCross.riscv64-embedded.buildPackages.gcc

      vivado
    ];

    buildPhase = ''
      ${pkgs.python38}/bin/python3.8 ./litex/boards/targets/arty.py \
        --uart-baudrate=1000000 \
        --cpu-variant=tock+secure+imc \
        --csr-data-width=32 \
        --timer-uptime \
        --integrated-rom-size=0xb000 \
        --with-ethernet \
        --build
    '';

    installPhase = ''
      mkdir -p $out
      cp -rf ./build/arty/* $out/
    '';
  }
