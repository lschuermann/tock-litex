# Tock on LiteX

This is a companion repository to running [Tock](https://github.com/tock/tock)
on [LiteX](https://github.com/enjoy-digital/litex) SoCs.

For more information on Tock, please visit the [website](https://tockos.org) and
[main repository](https://github.com/tock/tock).

## Contents

This repository contains build scripts for generating FPGA bitstreams, matching
the hardware expectations of the LiteX SoCs in the main Tock repository.

The [boards](https://github.com/tock/tock/tree/master/boards/litex) in Tock
target specific versions of the various LiteX cores & components, along with
certain configuration options. This repository pins tested versions of
repositories from the LiteX ecosystem. Generated artifacts and bitstreams are
uploaded & released on GitHub.

This repository aims to always track the Tock master branch and publish
compatible bitstreams.

Currently included boards are:
- Digilent Arty A7-35T: [digilent_arty.nix](./digilent_arty.nix)

## Prebuilt artifacts and bitstreams

The [GitHub releases page](https://github.com/lschuermann/tock-litex/releases)
contains prebuilt artifacts and releases (as [built
here](#Building-a-release)). These can be used to avoid downloading large FPGA
toolchains to build bitstreams or Scala for custom VexRiscv CPU variants.

## Installing dependencies and running LiteX Simulation (Verilator)

<details>
  <summary>Installation with the Nix package manager</summary>

  ### Installation with the Nix package manager

  To run the LiteX simulation, along with the corresponding [Tock board
  definition](https://github.com/tock/tock/tree/master/boards/litex), a
  `nix-shell` with all required dependencies can be entered:

  ```
  $ nix-shell shell.nix
  ```

  From within this environment all LiteX tools along with `litex_sim` are
  available.

  If desired, Xilinx Vivado can be made available in the shell by adding the
  appropriate argument:

  ```
  $ nix-shell --arg enableVivado true shell.nix
  ```
</details>

<details>
  <summary>Installation on other distributions (tested on Ubuntu 20.04)</summary>

  ### Installation on other distributions (tested on Ubuntu 20.04)

  These installation instructions have been tested on Ubuntu 20.04, but might
  work on other distributions as well. Package names and package manager
  commands might need to be substituted accordingly. Please don't blindly copy
  these commands.

  - Install required system-wide dependencies:
    ```
	$ sudo apt install verilator libevent-dev libjson-c-dev libz-dev \
        python3-pip python3-venv git unzip
	```
  - Setup a RISC-V toolchain. LiteX can use the `gcc-riscv64-unknown-elf`
    package:
	```
	$ sudo apt install gcc-riscv64-unknown-elf
	```

	However this package is missing some components required to build
    `libtock-c`. To have a toolchain which works for both `libtock-c` and the
    LiteX BIOS, install the toolchain as described in [`libtock-c` GitHub
    actions workflow][1]:
	```
	$ wget http://cs.virginia.edu/~bjc8c/archive/gcc-riscv64-unknown-elf-8.3.0-ubuntu.zip
	$ # Important: verify that the checksum matches. If the following command does not return "OK", do not continue!
	$ echo "2c82a8f3ac77bf2b24d66abff3aa5e873750c76de24c77e12dae91b9d2f4da27 gcc-riscv64-unknown-elf-8.3.0-ubuntu.zip" | sha256sum -c
	$ unzip gcc-riscv64-unknown-elf-8.3.0-ubuntu.zip
	$ export PATH=$PATH:"$(pwd)/gcc-riscv64-unknown-elf-8.3.0-ubuntu/bin"
	```
  - Get the `tock-litex` repository:
    ```
	$ git clone https://github.com/lschuermann/tock-litex
	$ cd ./tock-litex
	```
  - Create a Python virtual environment and install the LiteX packages:
    ```
	$ python3 -m venv ./tock-litex-env
	$ source ./tock-litex-env/bin/activate
	$ pip3 install -r requirements.txt
	```

  Now you should be ready to go. Be sure to remember setting the PATH correctly
  and entering the Python `venv` prior when trying to run `litex_sim`.  </details>

With all dependencies installed or the Nix shell environment activated, the
simulation can be started. When no Tock binary is available (or the greeting
does not appear), try removing the `--rom-init` option, which will boot the
LiteX BIOS instead.

```
$ litex_sim \
  --csr-data-width=32 \
  --integrated-rom-size=1048576 \
  --cpu-variant=secure \
  --with-ethernet \
  --rom-init $PATH_TO_TOCK_BINARY
[...]
make: Leaving directory '$(pwd)/build/sim/gateware'

[sudo] password for user:
[spdeeprom] loaded (addr = 0x0)
[...]
[clocker] sys_clk: freq_hz=1000000, phase_deg=0
Verilated LiteX+VexRiscv: initialization complete, entering main loop.
```

## Build instructions

While building board bitstreams currently depends on the Nix package manager
through the contained Nix derivations, efforts are made to allow building
without the Nix package manager installed in the future.

### Build a single board

To build a single board, run

```
$ nix-build $BOARD.nix
```

Note that this will use the default `nixpkgs` as defined in the environment for
downloading dependencies. It might take a while to build all dependencies.

By default, this will generate all LiteX artifacts, including the FPGA
bitstreams. To generate bitstreams for Xilinx FPGAs the proprietary Vivado
software suite is required, hence by default only the Verilog sources will be
generated for these respective boards. To attempt to build a bitstream using
Vivado, run the build using

```
$ nix-build $BOARD.nix --arg buildBitstream true
```

This will attempt to build a [Xilinx Vivado 2020.01 WebPack
derivation](./pkgs/vivado/default.nix) first. To use a custom Vivado derivation,
pass it in using the `vivado` argument. Due to sandboxing this path must point
to the Nix store.

### Building a release

To generate ZIPs for upload to GitHub, run

```
$ nix-build release.nix
```

The created target directory will contain the respective build artifacts as
`.zip` / `.tar.gz` archives.

## License

The code contained in this repository is licensed under either of

- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or
  http://www.apache.org/licenses/LICENSE-2.0)
- MIT license ([LICENSE-MIT](LICENSE-MIT) or
  http://opensource.org/licenses/MIT)

at your option.

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you, as defined in the Apache-2.0 license, shall be
dual licensed as above, without any additional terms or conditions.

This license does not necessarily apply to the packages built using this build
infrastructure. It might also not apply to patches included in this repository,
which may be derivative works of the packages to which they apply. The
aforementioned artifacts are all covered by the licenses of the respective
packages.

[1]: https://github.com/tock/libtock-c/blob/f69fec5790a8137ce58b77e48eaed6fadb98eba6/.github/workflows/ci.yml#L49-L51

<!--  LocalWords:  SoCs FPGA bitstreams LiteX Digilent digilent Prebuilt Scala
 -->
<!--  LocalWords:  toolchains Verilator Xilinx Vivado Ubuntu toolchain website
 -->
<!--  LocalWords:  BIOS workflow FPGAs Verilog bitstream sandboxing WebPack
 -->
<!--  LocalWords:  ZIPs
 -->
