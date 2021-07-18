{ fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "litehyperbus";
  rev = "b7d57e9c63b1f2"; # litehyperbus master of Jun 14, 2021, 8:03 AM GMT+2
  version = "git-${rev}";

  src = fetchFromGitHub {
    owner = "litex-hub";
    repo = pname;
    rev = rev;
    sha256 = "sha256-Xe3octAF+E124J5+1EQnSObuKqybu8SU/Ig38hWRcgE=";
  };

  buildInputs = [
    litex
    pyyaml
    migen
  ];

  # TODO: fix tests
  doCheck = false;
}
