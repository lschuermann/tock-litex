{ fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "litehyperbus";
  rev = "5282d5167c4c91"; # litepcie master of Nov 24, 2020, 1:45 PM GMT+1
  version = "git-${rev}";

  src = fetchFromGitHub {
    owner = "litex-hub";
    repo = pname;
    rev = rev;
    sha256 = "0y8cg8ai2rvszvcym9wads3sa38d4zhd4b28d342hgi242p6v3m9";
  };

  buildInputs = [
    litex
    pyyaml
    migen
  ];

  # TODO: fix tests
  doCheck = false;
}
