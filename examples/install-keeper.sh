ansible-playbook arizona_keeper_local.yml -i hosts/LOCAL/hosts --extra-vars "operation=install hostname=arizona_keeper"
ansible-playbook arizona_keeper_local.yml -i hosts/LOCAL/hosts --extra-vars "operation=localize hostname=arizona_keeper"
