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
        # Delete the old Verilog files, generate the complete set of
        # CPU variants
        rm pythondata_cpu_vexriscv/verilog/*.v

        # sbt tries to write into our home directory, which won't
        # work. Use a directory under /tmp instead.
        export SBT_OPTS="-Dsbt.global.base=/tmp/.sbt -Dsbt.ivy.home=/tmp/.ivy2"

        # Build all CPU variants
        make -C pythondata_cpu_vexriscv/verilog
      '';

      installPhase = ''
        # Remove any build artificats from sbt
        rm -rf pythondata_cpu_vexriscv/verilog/ext/VexRiscv/target
        rm -rf pythondata_cpu_vexriscv/verilog/ext/VexRiscv/project/{project,target}
        rm -rf pythondata_cpu_vexriscv/verilog/target
        rm -rf pythondata_cpu_vexriscv/verilog/project/{project,target}

        # VexRiscv writes the current timestamp into the generated
        # output, which breaks reproducability. Remove it.
        find . -iname '*.v' -execdir sed '/^\/\/ Date      :/d' -i {} \;

        # The output must be a single file, to allow generating &
        # verifying the fixed output hash. Therefore, compress as
        # .tar.gz
        #
        # This also removes metadata such as the username or the file
        # creation timestamp
        tar \
          --sort=name \
          --owner=root:0 --group=root:0 \
          --mtime='UTC 2020-01-01' \
          --transform 's|^|pythondata_cpu_vexriscv/|' \
          -zcvf $out .
      '';

      # This must be a fixed output derivation in order to allow sbt
      # to download dependencies
      #
      # We hope that the output hash is mostly stable, in particular
      # by deleting unnecessary build artifcats
      outputHash = "sha256:17h3sj2vn2202v4krfhdlfb230a98s2fjfskvgp6xz505skg77g0";
    };

in
  buildPythonPackage rec {
    pname = "pythondata-cpu-vexriscv";
    version = "patched-git-${src.upstreamRev}";

    src = customCpuVexRiscv;

    doCheck = false;
  }
