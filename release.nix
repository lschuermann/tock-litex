let
  pinnedPkgs =
    import (builtins.fetchTarball {
      # Descriptive name to make the store path easier to identify
      name = "nixpkgs-23.011-2024-01-10";
      # Commit hash for release-23.11 as of 2024-01-10
      url = "https://github.com/nixos/nixpkgs/archive/f8f40cae42c67b815b72b7b46b05e5b5074b51a0.tar.gz";
      # Hash obtained using `nix-prefetch-url --unpack <url>`
      sha256 = "sha256:1xy8pnhmknvggn9bcfd3h1l01dncckm6x13jc39z3mx3myjhni2d";
    }) {};

  zipDeriv = name: deriv: zipPath name deriv.version deriv;

  zipPath = dname: version: deriv: pinnedPkgs.stdenv.mkDerivation rec {
    name = "${dname}-${version}.zip";

    builder = pinnedPkgs.writeScript "build_${name}.zip.sh" ''
      #! ${pinnedPkgs.bash}/bin/bash

      # Support unpacking compressed archives with tar
      export PATH="${pinnedPkgs.gzip}/bin/:${pinnedPkgs.xz}/bin/:$PATH"

      # Try to identify the type output of the derivation. If it's
      # already a ZIP, simply copy that. If it's a know archive we can
      # unpack, unpack and repack as ZIP. If it's a directoy, ZIP it.
      MIME_TYPE="$(${pinnedPkgs.file}/bin/file -z --brief --mime-type "${deriv}")"
      echo "zipPath: input has mime type $MIME_TYPE" >&2

      if [[ "$MIME_TYPE" == "inode/directory" ]]; then
        echo "zipPath: zipping directory to $out" >&2
        pushd "${deriv}"
        ${pinnedPkgs.zip}/bin/zip -r "$out" .
        popd
      elif [[ "$MIME_TYPE" == "application/x-tar" ]]; then
        # This catches compressed tars as well
        echo "zipPath: unpacking tar archive and repacking as ZIP" >&2
        ${pinnedPkgs.coreutils}/bin/mkdir unpack
        pushd unpack
        ${pinnedPkgs.gnutar}/bin/tar -xvf "${deriv}"
        ${pinnedPkgs.zip}/bin/zip -r "$out" .
        popd
      else
        echo "zipPath: Unknown format, cannot continue." >&2
        exit 1
      fi
    '';
  };

  socs = enableVivado: {
    "digilent_arty_a7-35t" = (import ./digilent_arty.nix) {
      pkgs = pinnedPkgs;
      buildBitstream = enableVivado;
      vendorDependencies = true;
      variant = "a7-35t";
    };
    "digilent_arty_a7-100t" = (import ./digilent_arty.nix) {
      pkgs = pinnedPkgs;
      buildBitstream = enableVivado;
      vendorDependencies = true;
      variant = "a7-100t";
    };
    "digilent_nexys_video" = (import ./digilent_nexys_video.nix) {
      pkgs = pinnedPkgs;
      buildBitstream = enableVivado;
      vendorDependencies = true;
    };
  };

  lib = pinnedPkgs.lib;
  litexPkgs = import ./litex-pkgs.nix { pkgs = pinnedPkgs; skipLitexPkgChecks = false;};

in
  { enableVivado ? true }:
  pinnedPkgs.linkFarm ("tock-litex" + (if !enableVivado then "-novivado" else "")) (
    # Include the generated gateware and software for the SoCs
    (lib.mapAttrsToList (name: deriv: { name = "${name}.zip"; path = zipDeriv name deriv; }) (socs enableVivado))

    # Include the generated VexRiscv CPUs (from the
    # pythondata-cpu-vexriscv package with patches applied)
    ++ [{
      name = "pythondata-cpu-vexriscv_patched.zip";
      path = "${
        zipPath
          "pythondata-cpu-vexriscv_patched.zip"
          "${litexPkgs.pythondata-cpu-vexriscv.version}"
          "${litexPkgs.pythondata-cpu-vexriscv.src.overrideAttrs (old: old // {
            fixupPhase = "true";
          })}"
      }";
    }]

    # Include the patched litex package, which contains support for the new
    # TockSecureIMC CPU variants:
    ++ [{
      name = "litex_patched.zip";
      path = "${
        zipPath
          "litex_patched.zip"
          "${litexPkgs.litex.version}"
          "${litexPkgs.litex-unchecked.overrideAttrs (old: old // {
            phases = [ "unpackPhase" "patchPhase" "installPhase" ];
            outputs = [ "out" ];
            installPhase = ''
              mkdir -p $out
              cp -vr ./ $out/
            '';
          })}"
      }";
    }]

    # Warn if building bitstreams using Vivado has been disabled. The
    # release is incomplete and should not be published then.
    ++ (if (!enableVivado) then [{
      name = "VIVADO_BITSTREAM_BUILD_DISABLED";
      path = "/dev/null";
    }] else [])
  )
