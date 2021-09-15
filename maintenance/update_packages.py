#! /usr/bin/env python3

import subprocess
import tempfile
import toml
from git import Repo

package_meta_file = "pkgs/litex_packages.toml"

def prompt(message):
    reply = str(input("{} [y/n] ".format(message))).lower().strip()
    if reply[0] == 'y':
        return True
    if reply[0] == 'n':
        return False
    else:
        return prompt(message)

try:
    meta_file = open(package_meta_file, "r")
    meta = toml.load(meta_file)
    meta_file.close()
except FileNotFoundError:
    print("Package meta file \"{}\" not found. Are you in the repository root?"
          .format(package_meta_file))

print("Parsed package metadata from \"{}\"".format(package_meta_file))

for pname, package in meta.items():
    print("Processing package \"{}\"".format(pname))

    with tempfile.TemporaryDirectory(prefix=pname) as tmpdir:
        if set(["github_user", "github_repo", "git_revision"]) \
           <= set(package.keys()):
            github_user = package["github_user"]
            github_repo = package["github_repo"]
            git_revision = package["git_revision"]

            print("Checking for a new revision on the master branch of {}/{}".format(github_user, github_repo))
            r = Repo.clone_from("https://github.com/{}/{}.git".format(github_user, github_repo), tmpdir)

            head = r.commit('master')
            pinned = r.commit(git_revision)

            commit_count_diff = head.count() - pinned.count()
            assert commit_count_diff >= 0
            if commit_count_diff > 0:
                print("Current head has {} more commits:".format(commit_count_diff))
                print("  {}\n  \"{}\"\n  -- {}".format(head.tree, head.summary, head.authored_datetime))
                print("  vs")
                print("  {}\n  \"{}\"\n  -- {}".format(pinned.tree, pinned.summary, pinned.authored_datetime))
                if prompt("  -> Do you want to update?"):
                    meta[pname]["git_revision"] = str(head.tree)

                    print("Okay, obtaining Nix hash...")
                    hash = subprocess.check_output([
                        "nix-prefetch-url",
                        "--type",
                        "sha256",
                        "--unpack",
                        "https://github.com/{}/{}/archive/{}.tar.gz".format(
                            github_user,
                            github_repo,
                            git_revision,
                        ),
                    ]).decode("utf-8").strip()
                    print("...got hash {}".format(hash))
                    meta[pname]["github_archive_nix_hash"] = hash

with open("newtoml", "w") as newfile:
    toml.dump(meta, newfile)
