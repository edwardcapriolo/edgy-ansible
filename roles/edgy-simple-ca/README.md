# edgy-simple-ca

This role is not for production, there are other better ansible roles
and many organizations that have better systems. The purpose of the role is
to create material used to launch other components using PKI as an identity
and TLS whenever possible.

PKI is a usually a service that is "locked" down as the material generated.
Controls a majority of cryptography and identity for organizations. Implementations
vary drastically. 

If you want to submit a better role I am all for it.

# implementation notes
It is very hard to ansible this 'clean' as you generally have to
weave the PKI information in at multiple levels of each application
passwords and shell scripts have to weave there way into config files
or environment variables, and keys themselves have to be placed in directories.

We will do the best we can for a simple/sane implementation. We wish edgy to
give "production grade" setup of things, but we can not head on 
address the complexity of pki/vault implementation. Thus
we hide aware the complexity in some cases to focus on
"working software"

### Prerequisites

- Openssl tools
- keytool java

### steps

Generate a CA only once
```
sh examples/install-edgy-ca.sh 
```

Then generate a client from the CA

```
sh examples/install-edgy-client.sh
```

You should see a bunch of files inside the fileserver

```declarative
edward@fedora:~/edgy-ansible$ ls roles/edgy-simple-ca/files/
fedora.crt  fedora.key  myCA.crt  myCA.p12  myCA.srl
fedora.csr  fedora.p12  myCA.key  myCA.pem  myTruststore.jks

```
Zookeeper uses PKI so it is good simple test

```
sh examples/install-keeper.sh
```

It cant be started like so:
```
ssh edgy@localhost
cd /home/edgy/arizona-keeper/apache-zookeeper-3.9.3-bin/bin
./arizona-keeper-zkServer.sh start-foreground

```

Watch for sneaky messages like this in the logs
```
20:00:58.814 [main] ERROR org.apache.zookeeper.server.auth.X509AuthenticationProvider - Failed to create trust manager
org.apache.zookeeper.common.X509Exception$TrustManagerException: java.io.IOException: keystore password was incorrect
	at org.apache.zookeeper.common.X509Util.createTrustManager(X509Util.java:612)

```


