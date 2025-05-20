# edgy-simple-local-ca

This CA is not for production, there are other better ansible roles
and many organizations have better systems. The purpose of the role is
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
address the complexites of pki/vault implementation. Thus
we hide aware the complexites in some cases to focus on
"working software"

### Prerequisites

- Openssl tools






