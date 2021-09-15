{ pkgs, skipChecks ? true }:

let
  lib = pkgs.lib;

  # Use builtins.fromTOML if available, otherwise use remarshal to
  # generate JSON which can be read. Code taken from
  # nixpkgs/pkgs/development/tools/poetry2nix/poetry2nix/lib.nix.
  fromTOML = builtins.fromTOML or (
    toml: builtins.fromJSON (
      builtins.readFile (
        pkgs.runCommand "from-toml"
          {
            inherit toml;
            allowSubstitutes = false;
            preferLocalBuild = true;
          }
          ''
            ${pkgs.remarshal}/bin/remarshal \
              -if toml \
              -i <(echo "$toml") \
              -of json \
              -o $out
            ''
      )
    )
  );

  readTOML = path: fromTOML (builtins.readFile path);

  # Read the file containing the different LiteX and related packages'
  # versions. This is done to have a central place where versions can
  # be pinned, to allow users to choose between using a Nix derivation
  # or setting up a regular Python environment and manually collecting
  # the system dependencies.
  pkgMetas = readTOML ./litex_packages.toml;

  litexPackageDefinitions = checked: finalBuild: uncheckedPkgs: self:
    let
      breakRecursion = if checked then uncheckedPkgs else self;
    in
      {
        pythondata-software-compiler-rt = pkgs.callPackage (
          import ./pythondata-software-compiler-rt.nix pkgMetas.pythondata-software-compiler_rt) {};

        pythondata-misc-tapcfg = pkgs.callPackage (
          import ./pythondata-misc-tapcfg.nix pkgMetas.pythondata-misc-tapcfg) {};

        migen = pkgs.callPackage (import ./migen.nix pkgMetas.migen) {};

        litex = pkgs.callPackage (
          import ./litex pkgMetas.litex checked
        ) {
          python3Packages = pkgs.python3Packages // {
            pythondata-software-compiler-rt = self.pythondata-software-compiler-rt;
            migen = self.migen;

            # We use a potentially unchecked LiteDram derivation here
            # to break up the recursive dependency of LiteX ->
            # LiteDRAM -> LiteX. Because in LiteX this is only used
            # for tests, it's a better choice than to use a
            # potentially unchecked LiteX in LiteDRAM.
            litedram = breakRecursion.litedram;
          };
        };

        liteiclink = pkgs.callPackage (
          # LiteICLink tests seem to be broken
          import ./liteiclink.nix pkgMetas.liteiclink false # checked
        ) {
          python3Packages = pkgs.python3Packages // {
            litex = self.litex;
            migen = self.migen;
          };
        };


        litedram = pkgs.callPackage (
          import ./litedram.nix pkgMetas.litedram checked
        ) {
          python3Packages = pkgs.python3Packages // {
            pythondata-software-compiler-rt = self.pythondata-software-compiler-rt;
            migen = self.migen;

            litex = self.litex;
            liteiclink = self.liteiclink;
            litescope = self.litescope;
            pythondata-cpu-serv = self.pythondata-cpu-serv;
            pythondata-cpu-vexriscv = self.pythondata-cpu-vexriscv;
            litepcie = self.litepcie;
            pythondata-misc-tapcfg = self.pythondata-misc-tapcfg;

            # Use a potentially unchecked LiteEth derivation here to
            # break up the transitive recursive dependency of LiteDRAM
            # -> LiteEth -> LiteEth
            liteeth = breakRecursion.liteeth;

            # Use a potentially unchecked LiteX boards derivation here
            # to break up the recursive dependency of LiteDRAM ->
            # litex-boards -> LiteDRAM. Because in LiteDRAM this is
            # only used for tests, it's a better choice than to use a
            # potentially unchecked LiteDRAM in litex-boards.
            litex-boards = breakRecursion.litex-boards;
          };
        };

        pythondata-cpu-vexriscv = pkgs.callPackage ./pythondata-cpu-vexriscv {};

        litex-boards = pkgs.callPackage (
          import ./litex-boards.nix pkgMetas.litex-boards checked finalBuild
        ) {
          python3Packages = pkgs.python3Packages // {
            litedram = self.litedram;
            litex = self.litex;
            pythondata-cpu-vexriscv = self.pythondata-cpu-vexriscv;
            migen = self.migen;
            liteeth = self.liteeth;
            liteiclink = self.liteiclink;
            litepcie = self.litepcie;
          };
        };

        liteeth = pkgs.callPackage (
          import ./liteeth.nix pkgMetas.liteeth checked
        ) {
          python3Packages = pkgs.python3Packages // {
            migen = self.migen;
            litex = self.litex;
            liteiclink = self.liteiclink;
            litescope = self.litescope;
            litedram = self.litedram;

            # Use a potentially unchecked LiteX boards derivation here
            # to break up the recursive dependency of LiteEth ->
            # litex-boards -> LiteEth. Because in LiteEth this is only
            # used for tests, it's a better choice than to use a
            # potentially unchecked LiteEth in litex-boards.
            litex-boards = breakRecursion.litex-boards;
          };
        };

        # Required for LiteDRAM tests
        #
        # Not an "officially supported" CPU target for Tock
        pythondata-cpu-serv = pkgs.callPackage (
          import ./pythondata-cpu-serv.nix pkgMetas.pythondata-cpu-serv) {};

        litespi = pkgs.callPackage (
          import ./litespi.nix pkgMetas.litespi checked
        ) {
          python3Packages = pkgs.python3Packages // {
            litex = self.litex;
          };
        };

        litescope = pkgs.callPackage (
          import ./litescope.nix pkgMetas.litescope checked
        ) {
          python3Packages = pkgs.python3Packages // {
            litex = self.litex;
            liteiclink = self.liteiclink;
            litepcie = self.litepcie;

            inherit (self) litespi litehyperbus pythondata-cpu-vexriscv;

            # Only used for tests. Would create various cyclic
            # dependency reliationships, for instance with LiteEth /
            # LiteDRAM.
            litex-boards = breakRecursion.litex-boards;
            liteeth = breakRecursion.liteeth;
            litedram = breakRecursion.litedram;
          };
        };

        litehyperbus = pkgs.callPackage (
          import ./litehyperbus.nix pkgMetas.litehyperbus checked
        ) {
          python3Packages = pkgs.python3Packages // {
            migen = self.migen;
            litex = self.litex;
          };
        };

        litepcie = pkgs.callPackage (
          import ./litepcie.nix pkgMetas.litepcie checked
        ) {
          python3Packages = pkgs.python3Packages // {
            migen = self.migen;
            litex = self.litex;

            inherit (self) litespi litehyperbus liteiclink;

            litex-boards = breakRecursion.litex-boards;
            litedram = breakRecursion.litedram;
            liteeth = breakRecursion.liteeth;
          };
        };
      };

  uncheckedPkgs = finalBuild: lib.fix (litexPackageDefinitions false finalBuild null);
  checkedPkgs = lib.converge (litexPackageDefinitions true false (uncheckedPkgs false)) (uncheckedPkgs false);
  checkedFinalPkgs = litexPackageDefinitions true true checkedPkgs checkedPkgs;

in
  if skipChecks then (uncheckedPkgs true) else checkedFinalPkgs
