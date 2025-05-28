#ansible-playbook arizona_storage_compute_local.yml -i hosts/LOCAL/hosts \
#--extra-vars "operation=journalnode_service hostname=arizona_storage_compute service_command=start"

ansible-playbook arizona_storage_compute_local.yml -i hosts/LOCAL/hosts --extra-vars "operation=format_namenode hostname=arizona_storage_compute"


##ansible-playbook arizona_storage_compute_local.yml -i hosts/LOCAL/hosts --extra-vars "operation=format_zkfc hostname=arizona_storage_compute"

##ansible-playbook arizona_storage_compute_local.yml -i hosts/LOCAL/hosts \
#--extra-vars "operation=namenode_service hostname=arizona_storage_compute service_command=start"
