ansible-playbook --skip-tags gather_facts -v edgy_kafka_local.yml -i hosts/LOCAL/hosts --extra-vars "operation=topic_configuration hostname=edgy_kafka"
