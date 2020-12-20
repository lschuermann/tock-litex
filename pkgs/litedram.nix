{ fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "litedram";
  rev = "103072c68a";
  version = "git-${rev}";

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = "litedram";
    rev = rev;
    sha256 = "1dj4zy9zk9q4kh6x2byyzmq5ffwl4866vdrmcfjflsfdlcd0z805";
  };

  buildInputs = [
    litex pyyaml migen
  ];

  # TODO: Fix checks
  doCheck = false;
}
