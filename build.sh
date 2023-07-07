#!/usr/bin/env bash

echo "This should take about 6 minutes to complete."
echo "The time is now: $(date +"%I:%M:%S")"
echo ""
echo "It will pause for quite a while at: Waiting for SSH to become available."
echo "This pause aligns with the OS being installed with the preseed, and provisioned."
echo ""
echo "It will also pause for a little while at a few compression steps, including: update-initramfs: Generating /boot/initrd.img-5.10.0-12-arm64."
echo ""
echo "This script only produces a Debian 12, ARM64, Parallels box."
echo ""
echo "A debug flag for troubleshooting can be found in the packer hcl file."
echo ""
echo "This script will over-write an existing box in dist/"
read -p "Continue? [y/n]:" choice
case "$choice" in
    y|Y ) true;;
    n|N ) echo "aborting."; exit 0;;
    * ) echo "invalid input."; exit 1;;
esac

# as of 2023-Jul-06th there is a bug that requires this workaround/shim:
# https://github.com/Parallels/packer-plugin-parallels/issues/36
echo "Attempting to shim Parallels Virtualization SDK for Packer..."
if [ ! -f "/Library/Frameworks/Python.framework/Versions/3.7/lib/python3.7/site-packages/prlsdkapi.pth" ]
then
    echo "  Critical Error! Unable to find file: prlsdkapi.pth"
    echo "  Please install the Parallels Virtualization SDK (eg: `brew install parallels-virtualization-sdk`)"
    exit 1;
else
    echo "  Located prlsdkapi.pth"
fi
echo "  Detecting python version (for the binary that packer has hard-coded)..."
SYSTEM_PYTHON_VERSION=$(/usr/bin/python3 --version | cut -d ' ' -f 2 | cut -d '.' -f 1-2)
echo "  Detected python version: ${SYSTEM_PYTHON_VERSION}"
if [ ! -f "/Library/Developer/CommandLineTools/Library/Frameworks/Python3.framework/Versions/${SYSTEM_PYTHON_VERSION}/lib/python${SYSTEM_PYTHON_VERSION}/site-packages/prlsdkapi.pth" ]
then
    echo "  Symlink does not exist, it will be created."
    sudo ln -s /Library/Frameworks/Python.framework/Versions/3.7/lib/python3.7/site-packages/prlsdkapi.pth "/Library/Developer/CommandLineTools/Library/Frameworks/Python3.framework/Versions/${SYSTEM_PYTHON_VERSION}/lib/python${SYSTEM_PYTHON_VERSION}/site-packages/prlsdkapi.pth"
else
    echo "  Symlink already exists."
fi

export PYTHONPATH="/Library/Frameworks/ParallelsVirtualizationSDK.framework/Versions/Current/Libraries/Python/3.7"
packer init parallels-bookworm-arm64.pkr.hcl
packer build -color=true -force parallels-bookworm-arm64.pkr.hcl

echo "Build is complete!"
exit 0;
