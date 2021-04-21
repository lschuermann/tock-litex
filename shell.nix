# A nix-shell expression with the collection of build inputs for the
# various board expressions. Can be helpful when debugging LiteX.

{ pkgs ? (import <nixpkgs> {}), withVivado ? false }:

with pkgs;

let
  litexPkgs = import ./pkgs { inherit pkgs; };

in
  stdenv.mkDerivation {
    name = "litex-shell";
    buildInputs = with litexPkgs; [
      migen litex openocd
      litedram
      liteeth
      liteiclink
      litescope
      litepcie
      litehyperbus
      pythondata-cpu-vexriscv pkgsCross.riscv64.buildPackages.gcc gnumake

      # For simulation
      pythondata-misc-tapcfg libevent json_c verilator

      yosys nextpnr icestorm
    ] ++ (if withVivado then [(pkgs.callPackage ./pkgs/vivado {})] else []);
  }
