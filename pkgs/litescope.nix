{ fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "litescope";
  rev = "f7a9672284b01f"; # litescope master of Jan 4, 2021, 2:14 PM GMT+1
  version = "git-${rev}";

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = "litescope";
    rev = rev;
    sha256 = "1q9l3fvc0xpi76d05vfvswv275drci7zk1yf88cpg5q6a3lgbvf0";
  };

  buildInputs = [
    litex
  ];

  # TODO: Fix checks
  doCheck = false;
}
