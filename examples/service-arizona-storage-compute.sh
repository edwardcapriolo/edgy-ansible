ansible-playbook arizona_storage_compute_local.yml -i hosts/LOCAL/hosts --extra-vars "operation=all_service hostname=arizona_storage_compute service_command=$1"
