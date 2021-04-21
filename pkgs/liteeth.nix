{ fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "liteeth";
  rev = "392414eef8991d"; # liteeth master of Apr 8, 2021, 2:07 PM GMT+2
  version = "git-${rev}";

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = pname;
    rev = rev;
    sha256 = "025fi6q2grwkyx8d7m2wx1aq0chm82q5rj6azpj176f6mwz2hx3m";
  };

  buildInputs = [
    litex
  ];

  # TOOD: Fix tests
  doCheck = false;
}
