# Nix expression to build LiteX for a Digilent Nexys Video board.

let
  litexPkgs = pkgs: import ./litex-pkgs.nix {
    pkgs = pkgs;
    skipLitexPkgChecks = false;
  };
  support = import ./support.nix;

  # This will try to build a Xilinx Vivado 2020.01 installation. Feel
  # free to avoid evaluating this by either overriding the `vivado`
  # argument with a derivation providing a "bin/vivado" executable, or
  # set `buildBitstream` to `false`.
  nixLitexVivado = pkgs: (litexPkgs pkgs).vivado;

in
  { pkgs ? (import <nixpkgs> {})
  , vivado ? (nixLitexVivado pkgs)
  , buildBitstream ? false
  , vendorDependencies ? false
  }:

  pkgs.stdenv.mkDerivation {
    pname = "litex-nexys_video";
    version = (litexPkgs pkgs).litex-boards.version;

    src = (litexPkgs pkgs).litex-boards.src;

    buildInputs = with pkgs; with (litexPkgs pkgs); [
      python38

      litex litex-boards litedram liteeth liteiclink litepcie
      litehyperbus pythondata-cpu-vexriscv

      pkgsCross.riscv64-embedded.buildPackages.gcc
    ] ++ (
      # Vivado is only required if a bitstream is to be built
      if buildBitstream then [
        vivado
      ] else []
    );

    buildPhase = builtins.concatStringsSep " " ([
      "${pkgs.python38}/bin/python3.8 ./litex_boards/targets/digilent_nexys_video.py"
      "--uart-baudrate=1000000"
      "--cpu-variant=tock+secure+imc"
      "--csr-data-width=32"
      "--timer-uptime"
      "--integrated-rom-size=0xb000"
      "--with-ethernet"
      "--build"
    ] ++ (
      # Only build the bitstream if the user explicitly requests it
      if !buildBitstream then [ "--no-compile-gateware" ] else [])
    );

    installPhase = (
      if vendorDependencies then
        support.vendorDependencies "digilent_nexys_video"
      else
        ""
    ) + ''
      mkdir -p $out
      cp -rf ./build/digilent_nexys_video/* $out/
    '';
  }
