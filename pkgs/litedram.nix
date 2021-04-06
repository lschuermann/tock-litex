{ fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "litedram";
  rev = "26c9f82c1b3048"; # litedram master of Apr 1, 2021, 7:00 PM GMT+2
  version = "git-${rev}";

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = "litedram";
    rev = rev;
    sha256 = "0g8ilw3s8xk8ig7fm74dihc5yg1zlgj1s7vyrjhx4bmrhkgz5fxs";
  };

  buildInputs = [
    litex pyyaml migen
  ];

  # TODO: Fix checks
  doCheck = false;
}
