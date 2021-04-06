{ fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "liteiclink";
  rev = "3d8ecdbcf9f026"; # liteiclink master of Apr 1, 2021, 6:59 PM GMT+2
  version = "git-${rev}";

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = pname;
    rev = rev;
    sha256 = "0blvgg26pf174nl8gi91a3aahalav0l4fcqdyphhc2i49iz63rnr";
  };

  buildInputs = [
    litex migen
  ];

  # TODO: Reenable checks
  doCheck = false;
}
