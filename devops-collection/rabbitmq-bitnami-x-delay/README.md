#Rabbitmq bitnami with x-delay-message plugin ready
run:
* docker-compose up -d
* docker tag {your_image_id} registry.zooket.ir/devops-collection/rabbitmq-bitnami-x-delay:3.7-debian-9
* docker push registry.zooket.ir/devops-collection/rabbitmq-bitnami-x-delay:3.7-debian-9
