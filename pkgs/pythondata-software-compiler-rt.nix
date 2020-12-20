{ fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "pythondata-software-compiler-rt";
  version = "2020.08";

  src = fetchFromGitHub {
    owner = "litex-hub";
    repo = "pythondata-software-compiler_rt";
    rev = version;
    sha256 = "0b65dj95418j4pjqqkqjq5npnn1ih1789ba9575kxcljgj7r8xb7";
  };

  doCheck = false;
}
