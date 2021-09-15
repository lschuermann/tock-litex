pkgMeta: doChecks: { lib, fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "litex" + (lib.optionalString (!doChecks) "-unchecked");
  version = pkgMeta.git_revision;

  src = fetchFromGitHub {
    owner = pkgMeta.github_user;
    repo = pkgMeta.github_repo;
    rev = pkgMeta.git_revision;
    sha256 = pkgMeta.github_archive_nix_hash;
  };

  patches = [
    ./0001-Add-Tock-VexRiscv-cpu-variants.patch
  ];

  propagatedBuildInputs = with python3Packages; [
    # LLVM's compiler-rt data downloaded and importable as a python
    # package
    pythondata-software-compiler-rt

    pyserial migen requests colorama
  ];

  checkInputs = with python3Packages; [
    litedram
  ];

  doCheck = doChecks;
}
