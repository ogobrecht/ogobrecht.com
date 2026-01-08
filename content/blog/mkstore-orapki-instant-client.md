+++
title = "How to use mkstore and orapki with Oracle Instant Client"
date = "2020-07-29"
description = "Create and manage wallets without full client installation"
slug = "how-to-use-mkstore-and-orapki-with-oracle-instant-client"
aliases = ["/posts/2020-07-29-how-to-use-mkstore-and-orapki-with-oracle-instant-client/"]

[taxonomies]
tags = ["Oracle", "Wallet", "Script"]

[extra]
giscus = true
+++

For some years I use only the [Oracle Instant Client](https://www.oracle.com/database/technologies/instant-client.html). I had too often trouble with the full client installation on my corporate PCs under Windows, especially in the old Windows 32/64 bit times. The instant client can be used by download and extract one basic zip file and adding an entry to your path environment variable. If you want to use SQL*Plus and other tools you need to download two additional files - no drama, also without admin rights.

When I started to store the user details in wallet files I was wondering why Oracle does not deliver the mkstore and orapki tools with the instant client. I searched for a workaround and found some posts about it - including installing the full client or other software to get the tools. But I do not want to install additional software only for two small command-line tools. I found the final hint in an [old post from Andriy Dmytrenko](https://andriydmytrenko.wordpress.com/2013/07/01/using-the-secure-external-password-store-with-instant-client/). Seems that the two utilities are only shell scripts that are calling some Java libraries. The question was from which location I should take the needed libraries. Since I also have [SQLcl](https://www.oracle.com/database/technologies/appdev/sqlcl.html) on my PC I found the libs there. Below my final shell scripts for Windows - put them somewhere and have the path pointing to the directory where they are stored. If you need them for Linux you will find a way to do it by yourself:

mkstore.bat:

```bat
@echo off
rem inspiration: https://andriydmytrenko.wordpress.com/2013/07/01/using-the-secure-external-password-store-with-instant-client/

setlocal

rem get the command line arguments
set args=
:loop
  if !%1==! goto :done
  set args=%args% %1
  shift
  goto :loop
:done

rem set classpath for mkstore - align this to your local SQLcl installation
set sqlcl=c:\path\to\sqlcl\lib
set classpath=%sqlcl%\oraclepki.jar
set classpath=%classpath%;%sqlcl%\osdt_core.jar
set classpath=%classpath%;%sqlcl%\osdt_cert.jar

rem simulate mkstore command
java -classpath %classpath% oracle.security.pki.OracleSecretStoreTextUI %args%

endlocal
```

orapki.bat:

```bat
@echo off
rem inspiration: https://andriydmytrenko.wordpress.com/2013/07/01/using-the-secure-external-password-store-with-instant-client/

setlocal

rem get the command line arguments
set args=
:loop
  if !%1==! goto :done
  set args=%args% %1
  shift
  goto :loop
:done

rem set classpath for orapki - align this to your local SQLcl installation
set sqlcl=c:\path\to\sqlcl\lib
set classpath=%sqlcl%\oraclepki.jar
set classpath=%classpath%;%sqlcl%\osdt_core.jar
set classpath=%classpath%;%sqlcl%\osdt_cert.jar

rem simulate orapki command
java -classpath %classpath% oracle.security.pki.textui.OraclePKITextUI %args%

endlocal
```

If you need a starter on using mkstore and orapki then Tim Hall from Oracle Base has covered you with an [article about the secure external password store](https://oracle-base.com/articles/10g/secure-external-password-store-10gr2).

Happy password storing :-)

Ottmar
