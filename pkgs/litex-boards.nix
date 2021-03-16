{ fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "litex-boards";
  rev = "ef662035b13a65"; # litex-boards master of Mar 16, 2021, 10:42 AM GMT+1
  version = "git-${rev}";

  src = fetchFromGitHub {
    owner = "litex-hub";
    repo = pname;
    rev = rev;
    sha256 = "15r5icqpfa68kn6xa8gbgcw2kxqincs9qsy85hk4py1wdd1ln678";
  };

  buildInputs = [
    litex
  ];

  # TOOD: Fix tests
  doCheck = false;
}
