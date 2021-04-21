{ fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "litedram";
  rev = "c2a779df4658d5"; # litedram master of Apr 19, 2021, 1:40 PM GMT+2
  version = "git-${rev}";

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = "litedram";
    rev = rev;
    sha256 = "09r12f3sjl5gkc7chz4l1jf20arndawa903xvxy4q54kjg6p4fhj";
  };

  buildInputs = [
    litex pyyaml migen
  ];

  # TODO: Fix checks
  doCheck = false;
}
