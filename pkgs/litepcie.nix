{ fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "litepcie";
  rev = "68334fd93d078c"; # litepcie master of Jul 2, 2021, 3:46 PM GMT+2
  version = "git-${rev}";

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = pname;
    rev = rev;
    sha256 = "sha256-/XY3HoC3aJCsUZkRNJSZVE1UwrMHoear7CycAELtMtE=";
  };

  buildInputs = [
    litex
    pyyaml
    migen
  ];

  # TODO: fix tests
  doCheck = false;
}
