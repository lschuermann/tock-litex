# Tock on LiteX

This is a companion repository to running
[Tock](https://github.com/tock/tock) on
[LiteX](https://github.com/enjoy-digital/litex) SoCs.

For more information on Tock, please visit the
[website](https://tockos.org) and [main
repository](https://github.com/tock/tock).


## Contents

This repository contains build scripts for generating FPGA bitstreams,
matching the hardware expectations of the LiteX SoCs in the main Tock
repository.

The [boards](https://github.com/tock/tock/tree/master/boards/litex) in
Tock target specific versions of the varios LiteX cores & components,
along with certain configuration options. This repository pins tested
versions of repositories from the LiteX ecosystem. Generated artifacts
and bitstreams are uploaded & released on GitHub.

This repository aims to always track the Tock master branch and
publish compatible bitstreams.

Currently included boards are:
- Digilent Arty A7-35T: [digilent_arty.nix](./digilent_arty.nix)

## Prebuilt artifacts and bitstreams

The [GitHub releases
page](https://github.com/lschuermann/tock-litex/releases) contains
prebuilt artifacts and releases (as [built
here](#Building-a-release)). These can be used to avoid downloading
large FPGA toolchains to build bitstreams or Scala for custom VexRiscv
CPU variants.

## LiteX Simulation (Verilator)

To run the LiteX simulation, along with the corresponding [Tock board
definition](https://github.com/tock/tock/tree/master/boards/litex), a
`nix-shell` with all required dependencies can be entered:

```
$ nix-shell shell.nix
```

From within this enviroment all LiteX tools along with `litex_sim` are
available:

```
[nix-shell:~/tock-litex]$ litex_sim \
  --csr-data-width=32 \
  --integrated-rom-size=1048576 \
  --cpu-variant=secure \
  --with-ethernet \
  --rom-init $PATH_TO_TOCK_BINARY
[...]
make: Leaving directory '/home/leons/develop/tock/boards/litex/sim/build/sim/gateware'

[sudo] password for user:
[spdeeprom] loaded (addr = 0x0)
[...]
[clocker] sys_clk: freq_hz=1000000, phase_deg=0
Verilated LiteX+VexRiscv: initialization complete, entering main loop.
```

If desired, Xilinx Vivado can be made available in the shell by adding
the appropriate argument:

```
$ nix-shell --arg withVivado true shell.nix
```

## Build instructions

While building boards currently depends on the Nix package manager
through the contained Nix derivations, efforts are made to allow
building without the Nix package manager installed in the future.

### Build a single board

To build a single board, run

```
$ nix-build $BOARD.nix
```

Note that this will use the default nixpkgs as defined in the
environment for downloading dependencies. It might take a while to
build all dependencies.

By default, this will generate all LiteX artificats, including the
FPGA bitstreams. To generate bitstreams for Xilinx FPGAs the
proprietary Vivado software suite is required, hence by default only
the Verilog sources will be generated for these respective boards. To
attempt to build a bitstream using Vivado, run the build using

```
$ nix-build $BOARD.nix --arg buildBitstream true
```

This will attempt to build a [Xilinx Vivado 2020.01 WebPack
derivation](./pkgs/vivado/default.nix) first. To use a custom Vivado
derivation, pass it in using the `vivado` argument. Due to Sandboxing
this path must point to the Nix store.

### Building a release

To generate ZIPs for upload to GitHub, run

```
$ nix-build release.nix
```

The created target directory will contain the respective build
artifacts as `.zip` / `.tar.gz` archives.

## License

The code contained in this repository is licensed under either of


- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or
  http://www.apache.org/licenses/LICENSE-2.0)
- MIT license ([LICENSE-MIT](LICENSE-MIT) or
  http://opensource.org/licenses/MIT)

at your option.

Unless you explicitly state otherwise, any contribution intentionally
submitted for inclusion in the work by you, as defined in the
Apache-2.0 license, shall be dual licensed as above, without any
additional terms or conditions.

This license does not necessarily apply to the packages built using
this build infrastructure. It might also not apply to patches included
in this repository, which may be derivative works of the packages to
which they apply. The aforementioned artifacts are all covered by the
licenses of the respective packages.

