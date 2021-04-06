{ fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "litex";
  rev = "8db1a619f5edde"; # litex master of Apr 6, 2021, 12:27 PM GMT+2
  version = "git-${rev}";

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = "litex";
    rev = rev;
    sha256 = "12kxack4sz1sis2laixfzj3wy7kz7k1zw1jcvw2zchchz8vld9mf";
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
