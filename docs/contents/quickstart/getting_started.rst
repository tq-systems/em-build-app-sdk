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

#. **Adding a custom app**

    In order to develop your own custom app you can either modify the checked-out demo-app
    as a starting point or create a new app from scratch in a local directory.
    Add the app directory to the projects.yaml file.
    If you want your app to be built via app-sdk, make sure to add it to
    the app-sdk Makefile.

#. **Installing an app to a device**

    After compilation of a new app version you can install it directly
    to the device without the need of installing a whole bundle again.
    The new version will overlay the version installed with the bundle.

    You can install apps at runtime as follows:

    ./build/toolchain/scripts/em-app-install.sh root@<ip-address> <app-file>

#. **Uninstalling an app from a device**

    If you wish to remove a runtime-installed app and
    return to the version installed in the bundle (if any):

    ./build/toolchain/scripts/em-app-uninstall.sh root@<ip-address> <app-id>

#. **Adding a custom bundle**

    If you want an own custom bundle you can modify the demo-bundle or
    create a new bundle in a local directory.
    Add the bundle directory to the projects.yaml file.
    If you want your bundle to be built via app-sdk, make sure to add it to
    the app-sdk Makefile.

#. **Integration of custom app to custom bundle**

    If you want the custom app to be part of the bundle,
    add it to the bundle specification (demo-devel.yml).
    You must assign a version and a URL (file/https) for the binary.
