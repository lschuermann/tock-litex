{ fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "liteiclink";
  rev = "0980a7cf4ffcb0"; # liteiclink master of Jan 18, 2021, 9:14 AM GMT+1
  version = "git-${rev}";

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = pname;
    rev = rev;
    sha256 = "0gjwcqd1dwn6f8q3llj025aq3qsaclaf4pg7ss89b70v0ilya50y";
  };

  buildInputs = [
    litex migen
  ];

  # TODO: Reenable checks
  doCheck = false;
}
