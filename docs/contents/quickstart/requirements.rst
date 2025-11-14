System Requirements
-------------------

The build server has the following hardware requirements:

* Minimum 8 CPU cores
* Minimum 16 GB RAM
* Minimum 150 GB free storage

The initial build of the Linux distribution takes a very long time.
This process can be accelerated by using a large number of CPU cores and an SSD.
Incremental builds, on the other hand, save a considerable amount of time.

The build server has the following software requirements:

* Linux as the operating system (tested with Ubuntu 22.04 and 24.04)
* Git
* Docker
* Make
* Python 3.10 or later

You will also need a TQ Energy Manager `EM400 (Device Type: HW0200)` device to run
and test your applications.
