{ fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "litedram";
  rev = "4326fe7f36699a"; # litedram master of Jul 13, 2021, 2:57 PM GMT+2
  version = "git-${rev}";

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = "litedram";
    rev = rev;
    sha256 = "sha256-CUj5vQAT0eB1qT5+6kz5x/3/hty/UgqKwizoIx8BC6g=";
  };

  buildInputs = [
    litex pyyaml migen
  ];

  # TODO: Fix checks
  doCheck = false;
}
