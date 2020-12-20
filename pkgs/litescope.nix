{ fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "litescope";
  rev = "f78400aa29";
  version = "git-${rev}";

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = "litescope";
    rev = rev;
    sha256 = "16nqy53r15afc8aa58av131janjnlyr6zkmn5x66rggmndrlh00m";
  };

  buildInputs = [
    litex
  ];

  # TODO: Fix checks
  doCheck = false;
}
