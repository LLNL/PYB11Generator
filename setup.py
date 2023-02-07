# Distribution script for PYB11Generator pybind11 code generation package

import setuptools
import os, glob

with open("README.md", "r") as fh:
    long_description = fh.read()

cmake_files = glob.glob("cmake/*.cmake") + glob.glob("cmake/*.py")

# This base logic is cribbed from the pybind11 example.
# This will _not_ affect installing from wheels,
# only building wheels or installing from SDist.
# Primarily intended on Windows, where this is sometimes
# customized (for example, conda-forge uses Library/)
base = os.environ.get("PYBIND11_GLOBAL_PREFIX", "")

# Must have a separator
if base and not base.endswith("/"):
    base += "/"

setuptools.setup(
    name = "PYB11Generator",
    version = "2.0.2",
    author = "J. Michael Owen",
    author_email = "mikeowen@llnl.gov",
    description = "A code generator for the pybind11 C++ <-> Python language binding tool",
    long_description = long_description,
    long_description_content_type = "text/markdown",
    url = "https://github.com/jmikeowen/PYB11Generator",
    include_package_data = True,
    packages = setuptools.find_packages(),
    classifiers = [
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: BSD License",
        "Operating System :: OS Independent",
    ],
    install_requires = [
        "decorator",
        "pybind11"
    ],
    data_files = [
        (base + "cmake", cmake_files),
    ],
)
