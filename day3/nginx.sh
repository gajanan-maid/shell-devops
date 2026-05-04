#!/bin/bash
sudo yum update -y
sudo yum install docker -y
sudo systemctl start docker
sudo usermod -aG docker $USER

sudo chmod 666 /var/run/docker.sock

git --version

docker pull nginx:latest

#config container

container_name="con1"
image_name="nginx:latest"
host_port=8000
container_port=80 

 echo " --- Starting Rollout for $container_name --- "

#CHECK AND CREATION

if [ "$(docker ps -aq -f name=^/${container_name}$)" ]; then
    echo "Existing container found. Preparing to rollout..."

    # 2. Stop the old container
    echo "Stopping old container..."
    docker stop "$container_name" > /dev/null

    # 3. Remove the old container
    echo "Removing old container..."
    docker rm "$container_name" > /dev/null
else
    echo "No existing container found. Starting fresh..."
fi


# container creation
echo "Launching new container..."
docker run -d \
  --name "$container_name" \
  -p "$host_port:$container_port" \
  --restart unless-stopped \
  "$image_name"

#health check

if [ "$(docker inspect -f '{{.State.Running}}' $container_name)" == "true" ]; then
    echo "✅ Rollout successful! Container is running on port $host_port."
else
    echo "❌ Rollout failed. Check 'docker logs $container_name' for details."
    exit 1
fi
