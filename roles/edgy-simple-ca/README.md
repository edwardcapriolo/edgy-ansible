# edgy-simple-ca

This role is not for production, because it doesn't put passwords in a vault or keep the key materials in a safe place. 
The purpose of the role is to create material used to launch other components using PKI as an identity
and TLS whenever possible. This is for use in the "playground" of other roles in this playbook. However there is nothing
expressly wrong with the play as it generates materials in a reporoducable way.

If you want to submit a better role I am all for it.

# implementation notes
We will do the best we can for a simple/sane implementation. We wish edgy to
give "production grade" setup of things, but we can not head on 
address the complexity of pki/vault implementation. Thus,
we hide aware the complexity in some cases to focus on
"working software"

### Prerequisites

- Openssl tools
- keytool java

### steps

Create some settings. We chose hosts/LOCAL/host_vars. 

Note: for PKI/SSL/TLS hostnames are important. For example, "host verification" will fail if the hostname does not 
match the DNS etc. In this example "fedora" is physically the name of my laptop.

```

edgy_simple_file_root: /home/edward/edgy-ansible/roles/edgy-simple-ca/files
CA_PASS_YOU_SET: "itssecret"
CA_SUB: "/C=US/ST=New York/L=New York/O=arizone cert/OU=arizona unit/CN=teknek.io"
#This should not be the same password as the CRT as it only protects "shareable" information of the truststore
CA_TRUSTSTORE_PASSWORD: "itssecret"

CLIENT_FQDN: fedora
CLIENT_PASS_YOU_SET: "ssshhh"
CLIENT_SUB: "/C=US/ST=New York/L=New York/O=arizone cert/OU=arizona unit/CN={{ CLIENT_FQDN }}"
```

Generate a CA only once
```
sh examples/install-edgy-ca.sh 
```

Then generate a client from the CA

```
sh examples/install-edgy-client.sh
```

You should see a bunch of files inside the role's file directory:

```
edward@fedora:~/edgy-ansible$ ls roles/edgy-simple-ca/files/
fedora.crt  fedora.key  myCA.crt  myCA.p12  myCA.srl
fedora.csr  fedora.p12  myCA.key  myCA.pem  myTruststore.jks
```
Zookeeper uses PKI so it is good simple test

```
sh examples/install-keeper.sh
```

Start zookeeper in the foreground. HINT: use more to watch the startup.
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

We also have baked a CLI to use the secure zookeeper port

```
home/edgy/arizona-keeper/apache-zookeeper-3.9.3-bin/bin
./arizona-keeper-zkCli.sh -server fedora:2182
```