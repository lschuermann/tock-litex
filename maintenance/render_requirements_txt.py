#! /usr/bin/env python3

"""
Python script to render a requirements.txt for pip3 to read in. This can be
used to install most of the LiteX and related Python packages.

When called from the root of the repository, this will try to read
pkgs/litex_packages.toml, if necessary fetch required intermediate information,
and finally build a pip3-compatible requirements.txt file.
"""

import toml

package_meta_file = "pkgs/litex_packages.toml"
requirements_txt = ""

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

    if set(["github_user", "github_repo", "git_revision"]) \
       <= set(package.keys()):
        requirements_txt += "git+https://github.com/{}/{}@{}#egg={}\n".format(
            package["github_user"],
            package["github_repo"],
            package["git_revision"],
            pname,
        )
    elif "tarball_url" in package.keys():
        requirements_txt += "{}\n".format(package["tarball_url"])
    else:
        raise ValueError("No useable version information for package \"{}\" found"
                         .format(pname))

with open("./requirements.txt", "w") as requirements_file:
    requirements_file.write(requirements_txt)


