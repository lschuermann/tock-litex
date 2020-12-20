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


## Build instructions

While releases are built with the Nix package manager through the
contained Nix derivations, efforts are made to allow building without
the Nix package manager installed.

To generate ZIPs for upload to GitHub, run

```
$ nix-build release.nix
```

The created target directory will contain the respective build
artifacts as ZIP files.
