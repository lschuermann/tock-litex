{ stdenv, bash, coreutils, writeScript, gnutar, gzip, requireFile, patchelf, procps, makeWrapper,
  ncurses, zlib, libX11, libXrender, libxcb, libXext, libXtst,
  libXi, glib, freetype, gtk2, buildFHSUserEnv, gcc, ncurses5, glibc }:

let
  extractedSource = stdenv.mkDerivation rec {
    name = "vivado-2020.2-extracted";

    src = requireFile rec {
      name = "Xilinx_Unified_2020.2_1118_1232.tar.gz";
      url = "https://www.xilinx.com/member/forms/download/xef.html?filename=Xilinx_Unified_2020.2_1118_1232.tar.gz";
      sha256 = "08pdgqvhkkbi2lclz3420nr4b62yq6njvbzz5vgkiz1g814jf04a";
      message = ''
        Unfortunately, we cannot download file ${name} automatically.
        Please go to ${url} to download it yourself, and add it to the Nix store.

        Notice: given that this is a large (44GB) file, the usual methods of addings files
        to the Nix store (nix-store --add-fixed / nix-prefetch-url file:///) will likely not work.
        Use the method described here: https://nixos.wiki/wiki/Cheatsheet#Adding_files_to_the_store
      '';
    };

    buildInputs = [ patchelf ];

    builder = writeScript "${name}-builder" ''
      #! ${bash}/bin/bash
      source $stdenv/setup

      mkdir -p $out/
      tar -xvf $src --strip-components=1 -C $out/ Xilinx_Unified_2020.2_1118_1232/

      patchShebangs $out/
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        $out/tps/lnx64/jre11.0.2/bin/java
      sed -i -- 's|/bin/rm|rm|g' $out/xsetup
    '';
  };

  vivadoPackage = stdenv.mkDerivation rec {
    name = "vivado-2020.2";

    nativeBuildInputs = [ zlib ];
    buildInputs = [ patchelf procps ncurses makeWrapper ];

    extracted = "${extractedSource}";

    builder = ./builder.sh;
    inherit ncurses;

    libPath = stdenv.lib.makeLibraryPath [
      stdenv.cc.cc
      ncurses
      zlib
      libX11 libXrender libxcb libXext libXtst libXi
      freetype gtk2
      glib
    ];

    meta = {
      description = "Xilinx Vivado WebPack Edition";
      homepage = "https://www.xilinx.com/products/design-tools/vivado.html";
      license = stdenv.lib.licenses.unfree;
    };
  };

in
  buildFHSUserEnv {
    name = "vivado";
    targetPkgs = _pkgs: [
      vivadoPackage
    ];
    multiPkgs = pkgs: [
      coreutils gcc ncurses5 zlib glibc.dev
    ];
    runScript = "vivado";
  }
