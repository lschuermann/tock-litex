{ fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "pythondata-misc-tapcfg";
  version = "0e6809132b7a42"; # pythondata-misc-tapcfg master of Mar 5, 2021, 9:48 PM GMT+1

  src = fetchFromGitHub {
    owner = "litex-hub";
    repo = "pythondata-misc-tapcfg";
    rev = version;
    sha256 = "182m452iclahx1ipic0x7q4c9w33w6vfm9lz8zbx39zli9dg7l03";
  };

  doCheck = false;
}
