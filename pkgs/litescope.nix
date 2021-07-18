{ fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "litescope";
  rev = "72c9930705ccc5"; # litescope master of May 3, 2021, 12:12 PM GMT+2
  version = "git-${rev}";

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = "litescope";
    rev = rev;
    sha256 = "sha256-s0JrgAoxYgNOE9SEOWV869yqAeBEfiXSslKKhul8qhY=";
  };

  buildInputs = [
    litex
  ];

  # TODO: Fix checks
  doCheck = false;
}
