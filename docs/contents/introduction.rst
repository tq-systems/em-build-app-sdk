Introduction
============

What is the App SDK?
--------------------

The TQ Energy Manager Application Software Development Kit (shortened App SDK) is a comprehensive
development framework designed to build and deploy applications for the TQ Energy Manager
platform. This App SDK provides developers with the tools, libraries and infrastructure
necessary to create TQ Energy Manager applications and integrate them into a firmware with
a set of already existing TQ applications.

It provides a set of features:

* **Unified Build System**: The development framework is Make-based
* **Containerized Development Environments**: Ensure reproducible and isolated development setups
* **Yocto Integration**: Built on Yocto Project for creating a customized Linux distribution
* **Cross-Platform Development**: Support for ARM64 (aarch64) target platforms
* **Demo Application**: Ready-to-use example application
* **Demo Bundle**: Ready-to-use example firmware

You only need one project to start development:

    `https://github.com/tq-systems/em-build-app-sdk <https://github.com/tq-systems/em-build-app-sdk>`_

Purpose of this documentation
-----------------------------

Following a brief, motivating introduction, this document provides a quickstart guide to help you
begin development on the TQ Energy Manager with just a few commands. Furthermore, important
concepts and all essential relationships will be explained. While the focus is primarily on the big
picture, details will be explored where necessary. As defined in the attached Code Conventions,
more detailed documentation will be available in the README files of the projects.
