pkgMeta: { fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "litespi";
  rev = "51eabb52248ab5"; # litespi master of Jun 27, 2021, 9:21 PM GMT+2
  version = "git-${rev}";

  src = fetchFromGitHub {
    owner = "litex-hub";
    repo = pname;
    rev = rev;
    sha256 = "sha256-FxFsFx57d5PpymDf3c4ZArESiUMlSKFz/uImcpbcoQU=";
  };

  buildInputs = [
    litex
  ];
}
