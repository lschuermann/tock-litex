{ fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "litedram";
  rev = "f17037fdb22c87"; # litedram master of Mar 12, 2021, 2:29 PM GMT+1
  version = "git-${rev}";

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = "litedram";
    rev = rev;
    sha256 = "04jx3clsdppp3wnha1547v7r663cqs9dc2s336dv1acpsx68hp61";
  };

  buildInputs = [
    litex pyyaml migen
  ];

  # TODO: Fix checks
  doCheck = false;
}
