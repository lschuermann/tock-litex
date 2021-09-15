pkgMeta: doChecks: { lib, fetchFromGitHub, python3Packages, pkgsCross, verilator, gnumake, libevent, json_c, zlib, zeromq }:

with python3Packages;

buildPythonPackage rec {
  pname = "litedram" + (lib.optionalString (!doChecks) "-unchecked");
  version = pkgMeta.git_revision;

  src = fetchFromGitHub {
    owner = pkgMeta.github_user;
    repo = pkgMeta.github_repo;
    rev = pkgMeta.git_revision;
    sha256 = pkgMeta.github_archive_nix_hash;
  };

  buildInputs = [
    litex pyyaml migen
  ];

  checkPhase = ''
    export NIX_CFLAGS_COMPILE=" \
      -isystem ${libevent.dev}/include \
      -isystem ${json_c.dev}/include \
      -isystem ${zlib.dev}/include \
      -isystem ${zeromq}/include \
      $NIX_CFLAGS_COMPILE"
    export NIX_LDFLAGS=" \
      -L${libevent}/lib \
      -L${json_c}/lib \
      -L${zlib}/lib \
      -L${zeromq}/lib \
      $NIX_LDFLAGS"
    pytest -v test/
  '';

  checkInputs = with python3Packages; [
    # For test summary
    pandas numpy matplotlib

    # Proper check inputs. Some of these are really only required
    # because litex-boards needs them for importing all targets in its
    # __init__.py.
    litex pytest pyyaml pexpect pythondata-cpu-serv pythondata-cpu-vexriscv litescope
    pythondata-misc-tapcfg litex-boards liteeth liteiclink litepcie

    # For running the litex_sim (part of the dependencies for that are
    # already listed above). The gcc will pull in various libraries,
    # as this is not a full stdenv in the checkPhase.
    verilator gnumake libevent.dev json_c zlib zeromq

    # It doesn't really matter which cross-compilation toolchain is
    # used here. This choice seems to be built by Hydra so that should
    # be the fastest one to have available on most systems.
    pkgsCross.riscv64.buildPackages.gcc
  ];

  doCheck = doChecks;
}
