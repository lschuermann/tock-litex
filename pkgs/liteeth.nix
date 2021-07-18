{ fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "liteeth";
  rev = "947ed037202a99"; # liteeth master of Jul 16, 2021, 5:50 PM GMT+2
  version = "git-${rev}";

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = pname;
    rev = rev;
    sha256 = "sha256-muPIG+7d57OTLJ4i0JlADLmo18qFfQONjRCUVHUPvUE=";
  };

  buildInputs = [
    litex
  ];

  # TOOD: Fix tests
  doCheck = false;
}
