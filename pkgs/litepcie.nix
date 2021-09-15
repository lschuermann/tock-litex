pkgMeta: doChecks: { lib, fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "litepcie" + (lib.optionalString (!doChecks) "-unchecked");
  version = pkgMeta.git_revision;

  src = fetchFromGitHub {
    owner = pkgMeta.github_user;
    repo = pkgMeta.github_repo;
    rev = pkgMeta.git_revision;
    sha256 = pkgMeta.github_archive_nix_hash;
  };

  buildInputs = [
    litex
    pyyaml
    migen
  ];

  checkInputs = [
    litex-boards litedram liteeth litespi litehyperbus liteiclink
  ];

  doCheck = doChecks;
}
