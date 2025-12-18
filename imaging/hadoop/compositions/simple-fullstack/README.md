Simple fullstack
=======

This composition runs the hadoop components (nn, dn, rm, nm)
* fully networked
* no redundancy


http://localhost:9870/dfshealth.html#tab-datanode

Extra
============

No init container so uncomment and go
    #The docker init command recipe is painful remove comment to init
    #command: [ "namenode", "-format" ]
    command: [ "namenode" ]
