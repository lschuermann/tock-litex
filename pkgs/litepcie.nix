{ fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "litepcie";
  rev = "c4780c3140effa"; # litepcie master of Mar 18, 2021, 10:25 AM GMT+1
  version = "git-${rev}";

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = pname;
    rev = rev;
    sha256 = "0vm8qxwvpp2gw2nfbrsz0s21bhl064yc4s9xx1jpcsg1im5m56ch";
  };

  buildInputs = [
    litex
    pyyaml
    migen
  ];

  # TODO: fix tests
  doCheck = false;
}
