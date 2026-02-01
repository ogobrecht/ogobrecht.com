+++
title = "How to migrate Oracle Cloud wallet into existing auto_login_local wallet"
date = "2020-08-03"
description = "One secure wallet for all your connections, no need to provide passwords in SQL*Plus, SQLcl and SQL Developer"
slug = "how-to-migrate-oracle-cloud-wallet-into-existing-auto-login-local-wallet"
aliases = ["/posts/2020-08-03-how-to-migrate-oracle-cloud-wallet-into-existing-auto-login-local-wallet/"]

[taxonomies]
tags = ["Oracle", "Wallet", "Script"]

[extra]
giscus = true
+++

I started to store user credentials in wallet files for higher security in SQL scripts. If you do so you should also secure the access to your wallet files on the operating system level. This is especially true for auto-login wallets from the Oracle Cloud. To increase the security a bit further you can restrict the auto-login to the local user who created the wallet. To achieve this you need to create an own wallet with `orapki` instead of `mkstore`:

```sh
orapki wallet create \
  -wallet "path/to/my/wallet" \
  -pwd myPassword \
  -auto_login_local
```

You can then add new alias/user/password entries with mkstore (you need to add each alias to your tnsnames.ora):

```sh
mkstore \
  -wrl "path/to/my/wallet" \
  -createCredential myAlias myUser myPassword
```

If you use only the instant client and cannot find mkstore and orapki, then have a look at my [previous post](/blog/how-to-use-mkstore-and-orapki-with-oracle-instant-client/) on how to simulate these tools.

## The Migration

I assume you have set an environment variable called TNS_ADMIN pointing to your TNS directory. In this directory, you have your wallet files and also your existing tnsnames.ora and sqlnet.ora to successfully connect to your local Oracle instances.

Now you need to extract the downloaded cloud wallet - for security reasons it makes sense to create a temporary subdirectory in your TNS directory and extract the cloud wallet there. You need to migrate the entries from `tnsnames.ora` and `sqlnet.ora` into your own TNS files and align the path to your wallet directory. Additionally, you should also copy over the file `ojdbc.properties` if you do not have it already and you plan to use SQLcl or SQL Developer with your wallet.

My resulting sqlnet.ora:

```txt
WALLET_LOCATION = (SOURCE = (METHOD = file) (METHOD_DATA = (DIRECTORY = "C:\\path\\to\\my\\wallet")))
SSL_SERVER_DN_MATCH = yes
sqlnet.wallet_override = true
```

My resulting tnsnames.ora:

```txt
myCloudDbName_high, myAlias = (description = (...
myCloudDbName_medium        = (description = (...
myCloudDbName_low           = (description = (...
myCloudDbName_tp            = (description = (...
myCloudDbName_tpurgent      = (description = (...

myLocalDbName, myOtherAlias = (description = (...
...
```

That was the easy part, but how you migrate the needed private key and all certificates?

It took me some time to figure this out because most people seem to use the cloud wallet as it is. This is understandable since SQL Developer can direct use the zipped version of the wallet. But my target is not to manage the passwords in multiple places - the databases, multiple wallets, SQL Developer and possibly other tools. I want to manage the passwords only in the databases and in one wallet and use this wallet with all the tools - in my case SQL*Plus, SQLcl and SQL Developer.

First I tried to export the private key and all certificates from the cloud wallet and then import it into my wallet. I was not successful with this mostly because of the private key and unknown alias names - maybe I was too tired from all the try and error things on how to achieve this. I came finally up with the idea to use the cloud wallet Java KeyStore files and convert them into my wallet with the orapki method `jks_to_pkcs12`.

Migrate private key and certificate from cloud wallet:

```sh
orapki wallet jks_to_pkcs12 \
  -wallet "path/to/my/wallet" \
  -pwd myPassword \
  -keystore "path/to/cloud/wallet/keystore.jks" \
  -jkspwd myCloudWalletPassword
```

Migrate trusted certificates from cloud wallet:

```sh
orapki wallet jks_to_pkcs12 \
  -wallet "path/to/my/wallet" \
  -pwd myPassword \
  -keystore "path/to/cloud/wallet/truststore.jks" \
  -jkspwd myCloudWalletPassword
```

Finally, list the wallet content to see the migrated entries:

```sh
orapki wallet display -wallet . -pwd myPassword
# or
orapki wallet display -wallet . -pwd myPassword -complete
```

The final file list in my TNS directory (without the Java KeyStore files from the cloud wallet):

```sh
cwallet.sso
cwallet.sso.lck
ewallet.p12
ewallet.p12.lck
ojdbc.properties
sqlnet.ora
tnsnames.ora
```

I am now able to connect to my cloud database with the desired tools without providing user/password details (tested version):

- SQL*Plus (19.6): `sqlplus /@myAlias`
- SQLcl (20.2): `sql /@myAlias`
- SQL Developer (20.2): authentication type "OS", connection type "Custom JDBC" with URL `jdbc:oracle:thin:/@myAlias`

If you forgot which aliases you have configured in your wallet:

```sh
mkstore -wrl "path/to/my/wallet" -listCredential
```

Hope this helps someone else.

Happy developing and scripting :-)

Ottmar
