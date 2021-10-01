let
  pinnedPkgs =
    import (builtins.fetchTarball {
      # Descriptive name to make the store path easier to identify
      name = "nixos-unstable-2021-09-24";
      # Commit hash for nixos-unstable as of 2021-09-24
      url = "https://github.com/nixos/nixpkgs/archive/51bcdc4cdaac48535dabf0ad4642a66774c609ed.tar.gz";
      # Hash obtained using `nix-prefetch-url --unpack <url>`
      sha256 = "0zpf159nlpla6qgxfgb2m3c2v09fz8jilc21zwymm59qrq6hxscm";
    }) {};

  zipDeriv = name: deriv: zipPath name deriv.version deriv;

  zipPath = dname: version: deriv: pinnedPkgs.stdenv.mkDerivation rec {
    name = "${dname}-${version}.zip";

    builder = pinnedPkgs.writeScript "build_${name}.zip.sh" ''
      #! ${pinnedPkgs.bash}/bin/bash

      if [ ! -d "${deriv}" ]; then
        echo "Derivation ${deriv} is not a directory"
        exit 1
      fi

      cd "${deriv}"
      ${pinnedPkgs.zip}/bin/zip -r "$out" .
    '';
  };

  socs = enableVivado: {
    "digilent_arty_a7-35t" = (import ./digilent_arty.nix) {
      pkgs = pinnedPkgs;
      buildBitstream = enableVivado;
      vendorDependencies = true;
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
      path = "${zipPath "pythondata-cpu-vexriscv_patched.zip" "${litexPkgs.pythondata-cpu-vexriscv.version}" "${litexPkgs.pythondata-cpu-vexriscv.src}"}";
    }]

    # Warn if building bitstreams using Vivado has been disabled. The
    # release is incomplete and should not be published then.
    ++ (if (!enableVivado) then [{
      name = "VIVADO_BITSTREAM_BUILD_DISABLED";
      path = "/dev/null";
    }] else [])
  )
