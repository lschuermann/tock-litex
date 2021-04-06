{ pkgs }:

rec {
  migen = pkgs.callPackage ./migen.nix {};

  pythondata-cpu-vexriscv = pkgs.callPackage ./pythondata-cpu-vexriscv {};
  pythondata-software-compiler-rt = pkgs.callPackage ./pythondata-software-compiler-rt.nix {};
  pythondata-misc-tapcfg = pkgs.callPackage ./pythondata-misc-tapcfg.nix {};

  litex = pkgs.callPackage ./litex {
    python3Packages = pkgs.python3Packages // {
      pythondata-software-compiler-rt = pythondata-software-compiler-rt;
      migen = migen;
    };
  };

  litex-boards = pkgs.callPackage ./litex-boards.nix {
    python3Packages = pkgs.python3Packages // {
      litex = litex;
    };
  };

  litedram = pkgs.callPackage ./litedram.nix {
    python3Packages = pkgs.python3Packages // {
      pythondata-software-compiler-rt = pythondata-software-compiler-rt;
      migen = migen;
      litex = litex;
    };
  };

  liteeth = pkgs.callPackage ./liteeth.nix {
    python3Packages = pkgs.python3Packages // {
      litex = litex;
    };
  };

  liteiclink = pkgs.callPackage ./liteiclink.nix {
    python3Packages = pkgs.python3Packages // {
      litex = litex;
      migen = migen;
    };
  };

  litescope = pkgs.callPackage ./litescope.nix {
    python3Packages = pkgs.python3Packages // {
      litex = litex;
    };
  };

  litehyperbus = pkgs.callPackage ./litehyperbus.nix {
    python3Packages = pkgs.python3Packages // {
      migen = migen;
      litex = litex;
    };
  };

  litepcie = pkgs.callPackage ./litepcie.nix {
    python3Packages = pkgs.python3Packages // {
      migen = migen;
      litex = litex;
    };
  };
}
