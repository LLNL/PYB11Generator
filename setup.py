# Distribution script for PYB11Generator pybind11 code generation package

import setuptools

with open("README.md", "r") as fh:
    long_description = fh.read()

setuptools.setup(
    name="PYB11Generator",
    version="1.0.8",
    author="J. Michael Owen",
    author_email="mikeowen@llnl.gov",
    description="A code generator for the pybind11 C++ <-> Python language binding tool",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/jmikeowen/PYB11Generator",
    packages=setuptools.find_packages(),
    classifiers=[
        "Programming Language :: Python :: 2",
        "License :: OSI Approved :: BSD License",
        "Operating System :: OS Independent",
    ],
    install_requires=[
        "decorator",
        "pybind11"
    ],
)
