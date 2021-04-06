{ fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "liteeth";
  rev = "694cc81d77f98d"; # liteeth master of Mar 30, 2021, 10:35 AM GMT+2
  version = "git-${rev}";

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = pname;
    rev = rev;
    sha256 = "1rq2419ky1ifac56x1j2nqsab6jf6lv9d4wzard028kpxsnljy6j";
  };

  buildInputs = [
    litex
  ];

  # TOOD: Fix tests
  doCheck = false;
}
