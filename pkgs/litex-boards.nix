{ fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "litex-boards";
  rev = "443b954c0c12b2"; # litex-boards master of Apr 19, 2021, 3:11 PM GMT+2
  version = "git-${rev}";

  src = fetchFromGitHub {
    owner = "litex-hub";
    repo = pname;
    rev = rev;
    sha256 = "1bg8c76lqlwzlc16sahb57gayyqajg46rjl6rrlls8sv38y7p67i";
  };

  buildInputs = [
    litex
  ];

  # TOOD: Fix tests
  doCheck = false;
}
