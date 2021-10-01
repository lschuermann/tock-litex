pkgMetas: { stdenv, fetchurl, python3Packages }:

# A patched version of the pythondata-cpu-vexriscv repository,
# maintained at https://github.com/lschuermann/litex-vexriscv-custom
#
# Uses GitHub releases instead of storing all artifacts in the Git
# repo itself.

python3Packages.buildPythonPackage rec {
  pname = "pythondata-cpu-vexriscv";

  version = pkgMetas.version;

  src = fetchurl {
    url = pkgMetas.tarball_url;
    sha256 = pkgMetas.tarball_nix_hash;
  };

  doCheck = false;
}
