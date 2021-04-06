{ fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "litex-boards";
  rev = "03accabc257ca"; # litex-boards master of Mar 31, 2021, 9:48 AM GMT+2
  version = "git-${rev}";

  src = fetchFromGitHub {
    owner = "litex-hub";
    repo = pname;
    rev = rev;
    sha256 = "0lfbr6qhjgwbsw0p4zpfb6w3frsbnc9wnjw95klkjan8dhi9c8y1";
  };

  buildInputs = [
    litex
  ];

  # TOOD: Fix tests
  doCheck = false;
}
