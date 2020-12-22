{ stdenv, fetchFromGitHub, python3Packages, scala, sbt }:

with python3Packages;

let
  customCpuVexRiscv =
    stdenv.mkDerivation rec {
      upstreamName = "pythondata-cpu-vexriscv";
      upstreamRev = "16c5dded21";

      name = "${upstreamName}-patched-${version}.tar.gz";
      version = "git-${upstreamRev}";

      src = fetchFromGitHub {
        owner = "litex-hub";
        repo = upstreamName;
        rev = upstreamRev;
        sha256 = "1z20r06vl7a5h3lnq5769vlp6npgld4fqk8cgm911z4gx1q743vj";
        fetchSubmodules = true;
      };

      nativeBuildInputs = [ scala sbt ];

      patches = [
        ./0001-Add-TockSecureIMC-cpu-variant.patch
      ];

      buildPhase = ''
        export SBT_OPTS="-Dsbt.global.base=/tmp/.sbt -Dsbt.ivy.home=/tmp/.ivy2"
        rm pythondata_cpu_vexriscv/verilog/*.v
        make -C pythondata_cpu_vexriscv/verilog
      '';

      # The output must be a single file, to allow generating &
      # verifying the fixed output hash. Therefore, compress as
      # .tar.gz
      installPhase = ''
        rm -rf pythondata_cpu_vexriscv/verilog/ext/VexRiscv/target
        rm -rf pythondata_cpu_vexriscv/verilog/target
        tar --transform 's|^|pythondata_cpu_vexriscv/|' -zcvf $out .
      '';

      # This must be a fixed output derivation in order to allow sbt
      # to download dependencies
      #
      # We hope that the output hash is mostly stable, in particular
      # by deleting unnecessary build artifcats
      outputHash = "sha256:052cxiv5i1shyflv5aghlwjb4lxgp5y61b78ymqnxgz1826qqv8b";
    };

in
  buildPythonPackage rec {
    pname = "pythondata-cpu-vexriscv";
    version = "patched-git-${src.upstreamRev}";

    src = customCpuVexRiscv;

    doCheck = false;
  }
