{ fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "migen";
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "m-labs";
    repo = "migen";
    rev = version;
    sha256 = "1kq11if64zj84gv4w1q7l16fp17xjxl2wv5hc9dibr1z3m1gy67l";
  };

  buildInputs = [
    colorama
  ];
}
