{ fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "litex-boards";
  rev = "4b48f15265c902"; # litex-boards master of Jul 16, 2021, 2:41 PM GMT+2
  version = "git-${rev}";

  src = fetchFromGitHub {
    owner = "litex-hub";
    repo = pname;
    rev = rev;
    sha256 = "sha256-SJ/xhAfdQDerwIUl1aLt+I3BdkNHHIZ6bjTug/0Mu3g=";
  };

  buildInputs = [
    litex
  ];

  # TOOD: Fix tests
  doCheck = false;
}
