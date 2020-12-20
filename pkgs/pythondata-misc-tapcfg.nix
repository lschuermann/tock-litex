{ fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "pythondata-misc-tapcfg";
  version = "2020.08";

  src = fetchFromGitHub {
    owner = "litex-hub";
    repo = "pythondata-misc-tapcfg";
    rev = version;
    sha256 = "0zr6d5giqzsjmqpfyf1b25r0y70bj09xjbfinfxcdc6s8cwwwz71";
  };

  doCheck = false;
}
