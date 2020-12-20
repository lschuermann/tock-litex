{ fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "liteeth";
  rev = "e270956d2d";
  version = "git-${rev}";

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = pname;
    rev = rev;
    sha256 = "1fqzhzgp2hdcpk8z59iqc6j4zxklpldd32z03b9n5jd2kkz66scv";
  };

  buildInputs = [
    litex
  ];

  # TOOD: Fix tests
  doCheck = false;
}
