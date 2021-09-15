pkgMeta: { fetchFromGitHub, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "migen";
  version = pkgMeta.git_revision;

  src = fetchFromGitHub {
    owner = pkgMeta.github_user;
    repo = pkgMeta.github_repo;
    rev = pkgMeta.git_revision;
    sha256 = pkgMeta.github_archive_nix_hash;
  };


  buildInputs = [
    colorama
  ];

  doChecks = true;
}
