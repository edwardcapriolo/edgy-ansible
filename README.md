# edgy-ansible
Edgy (ED GuY) is about Capabilities 

Things Edgy is about:

- Capabilities: You want to do things, you want object storage, you want a lock manager
- Reproducability: Automate all thing (up to the point automation is less productive then doing manually) 
- Simplicity: Make it easy to install, make as few changes as possible upstream to make it work
- Fast: Install quickly get live quickly
- Good: Made for purpose, 'production grade' when possible, otherwise clean explain clearly gaps
- Secure: PKI/SSL/TLS default limit 'punting' in the form of 'secuity comes later' 
- No picking winners

## What is here?

- [edgy-simple-ca](roles/edgy-simple-ca/README.md) a simple CA that is used by other playbooks
- [arizona-keeper](roles/arizona-keeper/README.md) a zookeeper role with TLS security
- [arizona-storage-compute](roles/arizona-storage-compute/README.md) HDFS and YARN HA no SPOF

## Why not Ansible galaxy?

No shame in my game. I don't know ansible galaxy. Send a PR

## Why not Docker/ Kuberneties Operators

The focus for edgy isn't  "packaging". Over 20 years I have used
rpm/shellscripts/radmind/Puppet/Ansible/Shell scripts/Jib Plugin/apko/teraform everyone has great opinions on what 
the best system to do something is. Thats great, when I get some cycles I will look into how the ansible could be used 
in docker build or how the plays can go into k8s operators. 
