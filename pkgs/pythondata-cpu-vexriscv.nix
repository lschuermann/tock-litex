{ fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "pythondata-cpu-vexriscv";
  version = "git-${rev}";
  rev = "16c5dded21";

  src = fetchFromGitHub {
    inherit rev;

    owner = "litex-hub";
    repo = pname;
    sha256 = "0cbs3a5wllp8n91mh1q22fsqw7n4k8npssa5i3alspmb8m56ivhm";
  };

  doCheck = false;
}
