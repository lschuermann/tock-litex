{ fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "liteeth";
  rev = "6c3af746e28f55"; # liteeth master of Mar 11, 2021, 11:55 AM GMT+1
  version = "git-${rev}";

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = pname;
    rev = rev;
    sha256 = "0fr2ylwqmicf9n28df9v9g116k04by6spkc1p1cjfmj53si8pchl";
  };

  buildInputs = [
    litex
  ];

  # TOOD: Fix tests
  doCheck = false;
}
