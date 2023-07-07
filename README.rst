Vagrant Packer Debian Bookworm ARM64
====================================

This project is intentionally narrow in what it provides. It will use `Packer
by Hashcorp <https://www.packer.io>`_ to create a Parallels box with Debian
12.0 (Bookworm) for ARM64 (to run on, for example, Apple's new M1/M2 machines).
It does this using the new HCL syntax (instead of the legacy JSON syntax). Run
:code:`./build.sh` to generate the box.

The box can then be added like: :code:`vagrant box add testing dist/parallels/bookworm-arm64.box`

https://github.com/BytesGuy/arm-base-boxes was a great resource

https://github.com/Yoshi325/Vagrant-Packer-Debian-Bullseye-Arm64 was created for the previous version of Debian.


Dependencies
------------
* XCode Command Line Tools (:code:`xcode-select --install`)
* Parallels Virtualization SDK (:code:`brew install parallels-virtualization-sdk`)
* Hashcorp Packer (:code:`brew install packer`)

Common Errors
-------------

Failed creating Parallels driver: Parallels Virtualization SDK is not installed:
    $ brew install parallels-virtualization-sdk
