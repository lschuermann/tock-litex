{ fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "litex";
  rev = "b55af2156ba338"; # litex master of Apr 21, 2021, 1:38 PM GMT+2
  version = "git-${rev}";

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = "litex";
    rev = rev;
    sha256 = "1y3s5dxw2jwxklyj1b7z72gmc5cs2kbiqqqpn45rfs14dxnmc73v";
  };

  patches = [
    ./0001-Add-Tock-VexRiscv-cpu-variants.patch
  ];

  propagatedBuildInputs = [
    # LLVM's compiler-rt data downloaded and importable as a python
    # package
    pythondata-software-compiler-rt

    pyserial migen requests colorama
  ];

  doCheck = false;
}
