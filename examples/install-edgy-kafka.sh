ansible-playbook edgy_kafka_local.yml -i hosts/LOCAL/hosts --extra-vars "operation=install hostname=edgy_kafka"
ansible-playbook edgy_kafka_local.yml -i hosts/LOCAL/hosts --extra-vars "operation=localize hostname=edgy_kafka"
