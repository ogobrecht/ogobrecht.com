+++
title = "Oracle DB 11gXE Install File Swap Check Disabler"
date = "2017-06-13"
description = "A Docker file to prepare the 11gXE install file for use in a container environment"
slug = "ora11xe-install-file-swap-check-disabler"
aliases = ["/posts/2017-06-13-ora11xe-install-file-swap-check-disabler/"]

[taxonomies]
tags = ["Oracle", "Database", "Docker", "Container"]
+++

Many people have problems to install Oracle 11XE in a Docker environment because the install file checks the available swap space in the container. In a container environment this fails often - see [here](https://github.com/oracle/docker-images/issues/294#issuecomment-301465754) or [here](https://www.elastichosts.com/blog/oracle-database-installation-on-a-container-running-centos/), because the swap space is optimized for the entire stack and not controlled from within the operating system of the container.

We have to disable the swap space check in the installation file. I wrote another [blog post about this](/blog/pitfalls-with-oracle-11g-xe-and-docker-on-mac-os). The problem is here, that you need a Linux based system to do the necessary steps. Under Windows you have no chance and you have to do it by yourself because for license reasons everyone has to download his/her own copy of the install file from [Oracle OTN](http://www.oracle.com/technetwork/database/database-technologies/express-edition/downloads/index.html).

I came up with the idea to simply do all the steps in a Docker container under the same Linux (oraclelinux:7-slim) which is later on needed with the [official Oracle Docker file](https://github.com/oracle/docker-images/blob/master/OracleDatabase/dockerfiles/11.2.0.2/Dockerfile.xe) for an XE instance. With this solution you are able to prepare the install file more or less automatically under every operating system, which can run Docker - also under Windows. For more Details see the [project on GitHub](https://github.com/ogobrecht/docker-ora11xe-swap-check-disabler).

Happy installing :-)

Ottmar
