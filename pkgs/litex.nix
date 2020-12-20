{ fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "litex";
  rev = "4092180662";
  version = "git-${rev}";

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = "litex";
    rev = rev;
    sha256 = "000cvcykfkpr9mkfaq29ql9jn3dc72m5hwa95b39m4rfglvdqb0i";
  };

  propagatedBuildInputs = [
    # LLVM's compiler-rt data downloaded and importable as a python
    # package
    pythondata-software-compiler-rt

    pyserial migen requests colorama
  ];

  doCheck = false;
}
