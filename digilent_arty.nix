# Nix expression to build LiteX for a Digilent Arty A7-35T board.
#
# This expression aims to generate a bitstream compatible with the
# [Tock litex/arty board
# definition](https://github.com/tock/tock/tree/master/boards/litex/arty).

let
  litexPkgs = pkgs: import ./litex-pkgs.nix {
    pkgs = pkgs;
    skipLitexPkgChecks = true;
  };
  support = import ./support.nix;

  # This will try to build a Xilinx Vivado 2020.01 installation. Feel
  # free to avoid evaluating this by either overriding the `vivado`
  # argument with a derivation providing a "bin/vivado" executable, or
  # set `buildBitstream` to `false`.
  nixLitexVivado = pkgs: (litexPkgs pkgs).vivado;

  # This is not only a purposeless translation of strings removing
  # the t at the end, but also throws an error for invalid variants.
  litexVariantString = variant:
    if variant == "a7-35t" then
      "a7-35"
    else if variant == "a7-100t" then
      "a7-100"
    else
      abort "Unknown Arty-A7 variant string!";

in
  { pkgs ? (import <nixpkgs> {})
  , vivado ? (nixLitexVivado pkgs)
  , buildBitstream ? false
  , vendorDependencies ? false
  , variant ? "a7-35t"
  }:

  pkgs.stdenv.mkDerivation {
    pname = "litex-arty-${variant}";
    version = (litexPkgs pkgs).litex-boards.version;

    src = (litexPkgs pkgs).litex-boards.src;

    buildInputs = with pkgs; with (litexPkgs pkgs); [
      python38

      litex litex-boards litedram liteeth liteiclink litepcie
      litehyperbus litespi pythondata-cpu-vexriscv

      pkgsCross.riscv64-embedded.buildPackages.gcc
    ] ++ (
      # Vivado is only required if a bitstream is to be built
      if buildBitstream then [
        vivado
      ] else []
    );

    buildPhase = builtins.concatStringsSep " " ([
      "${pkgs.python38}/bin/python3.8 ./litex_boards/targets/digilent_arty.py"
      "--uart-baudrate=1000000"
      "--cpu-variant=tock+secure+imc"
      "--csr-data-width=32"
      "--timer-uptime"
      "--integrated-rom-size=0xb000"
      "--with-ethernet"
      "--variant=${litexVariantString variant}"
    ] ++ (
      # Only build the bitstream if the user explicitly requests it
      if buildBitstream then [ "--build" ] else [])
    );

    installPhase = (
      if vendorDependencies then
        support.vendorDependencies "digilent_arty"
      else ""
    ) + ''
      mkdir -p $out
      cp -rf ./build/digilent_arty/* $out/
    '';
  }

