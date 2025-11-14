Getting Started
---------------

To begin development with the App SDK:

#. **Prerequisites**

    Ensure that your build host fulfils the hardware and software requirements
    listed in the previous section.

#. **Clone the App SDK project**

    git clone https://github.com/tq-systems/em-build-app-sdk

#. **Build the Toolchain, the Demo Application and the Demo Bundle**

    make all

#. **Install the Demo Bundle to the Energy Manager**

    ./build/toolchain/scripts/em-bundle-install.sh root@<ip-address> <bundle-file>

    The Energy Manager needs to be accessible via SSH and its root password is required.
    After successfully installing the bundle, you can ensure that the entire setup is working.
    Now you can create a new app or customize the demo app.
    Individual apps can be installed as follows:

    ./build/toolchain/scripts/em-app-install.sh root@<ip-address> <app-file>
