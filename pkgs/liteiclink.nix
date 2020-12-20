{ fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "liteiclink";
  rev = "8b29505096";
  version = "git-${rev}";

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = pname;
    rev = rev;
    sha256 = "0fp38df0rcd751r36k4sqqxpdwmy49mgbkwcj0mwc5y9mr0fgspy";
  };

  buildInputs = [
    litex migen
  ];

  # TODO: Reenable checks
  doCheck = false;
}
