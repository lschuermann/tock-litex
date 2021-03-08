let
  pinnedPkgs =
    import (builtins.fetchTarball {
      # Descriptive name to make the store path easier to identify
      name = "nixos-20.09-2021-03-03";
      # Commit hash for nixos-20.09 as of 2021-03-03
      url = "https://github.com/nixos/nixpkgs/archive/4d0ee90c6e253d40920f8dae5edb717a7d6f151d.tar.gz";
      # Hash obtained using `nix-prefetch-url --unpack <url>`
      sha256 = "sha256:0i4w6zfj1pz52lnpdz4qn9m8d96zlmwfgizi5dsdy3vcqxdwkqi3";
    }) {};


  zipDeriv = name: deriv: pinnedPkgs.stdenv.mkDerivation {
    name = "${name}.zip";
    version = deriv.version;

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
    "arty_a7-35t" = (import ./arty.nix) { pkgs = pinnedPkgs; buildBitstream = enableVivado; };
  };

  lib = pinnedPkgs.lib;
  litexPkgs = import ./pkgs { pkgs = pinnedPkgs; };

in
  { enableVivado ? true }:
  pinnedPkgs.linkFarm ("tock-litex" + (if !enableVivado then "-novivado" else "")) (
    # Include the generated gateware and software for the SoCs
    (lib.mapAttrsToList (name: deriv: { name = "${name}.zip"; path = zipDeriv name deriv; }) (socs enableVivado))

    # Include the generated VexRiscv CPUs (from the
    # pythondata-cpu-vexriscv package with patches applied)
    ++ [{
      name = "pythondata-cpu-vexriscv_patched.tar.gz";
      path = "${litexPkgs.pythondata-cpu-vexriscv.src}";
    }]

    # Warn if building bitstreams using Vivado has been disabled. The
    # release is incomplete and should not be published then.
    ++ (if (!enableVivado) then [{
      name = "VIVADO_BITSTREAM_BUILD_DISABLED";
      path = "/dev/null";
    }] else [])
  )
