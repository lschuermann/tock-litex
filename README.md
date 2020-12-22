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

