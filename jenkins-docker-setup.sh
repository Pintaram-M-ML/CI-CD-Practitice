#!/bin/bash

# Jenkins Docker Setup Script
# This script helps configure Docker access for Jenkins

echo "========================================="
echo "Jenkins Docker Setup"
echo "========================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Get Jenkins container name
echo "Enter your Jenkins container name (default: jenkins):"
read -r JENKINS_CONTAINER
JENKINS_CONTAINER=${JENKINS_CONTAINER:-jenkins}

# Check if container exists
if ! docker ps -a --format '{{.Names}}' | grep -q "^${JENKINS_CONTAINER}$"; then
    echo "❌ Container '${JENKINS_CONTAINER}' not found!"
    echo "Available containers:"
    docker ps -a --format "table {{.Names}}\t{{.Status}}"
    exit 1
fi

echo "✅ Found Jenkins container: ${JENKINS_CONTAINER}"

# Install Docker in Jenkins container
echo ""
echo "📦 Installing Docker in Jenkins container..."
docker exec -u root ${JENKINS_CONTAINER} bash -c '
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    
    # Add Docker GPG key
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Add Docker repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker
    apt-get update
    apt-get install -y docker-ce-cli docker-compose-plugin
    
    # Add jenkins user to docker group
    usermod -aG docker jenkins
    
    echo "✅ Docker installed successfully!"
'

# Mount Docker socket
echo ""
echo "🔗 Configuring Docker socket access..."

# Stop Jenkins container
echo "Stopping Jenkins container..."
docker stop ${JENKINS_CONTAINER}

# Get current container configuration
JENKINS_IMAGE=$(docker inspect ${JENKINS_CONTAINER} --format='{{.Config.Image}}')
JENKINS_VOLUMES=$(docker inspect ${JENKINS_CONTAINER} --format='{{range .Mounts}}{{.Source}}:{{.Destination}} {{end}}')

echo "Creating new Jenkins container with Docker socket mounted..."

# Remove old container
docker rm ${JENKINS_CONTAINER}

# Create new container with Docker socket
docker run -d \
    --name ${JENKINS_CONTAINER} \
    -p 8080:8080 \
    -p 50000:50000 \
    -v jenkins_home:/var/jenkins_home \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --group-add $(stat -c '%g' /var/run/docker.sock) \
    ${JENKINS_IMAGE}

echo ""
echo "✅ Jenkins container recreated with Docker access!"

# Wait for Jenkins to start
echo "Waiting for Jenkins to start..."
sleep 10

# Verify Docker access
echo ""
echo "🔍 Verifying Docker access..."
docker exec ${JENKINS_CONTAINER} docker --version

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================="
    echo "✅ Setup Complete!"
    echo "========================================="
    echo "Jenkins is now configured with Docker access"
    echo "Jenkins URL: http://localhost:8080"
    echo ""
    echo "Next steps:"
    echo "1. Log in to Jenkins"
    echo "2. Run your pipeline"
    echo "3. Docker commands should now work!"
    echo "========================================="
else
    echo ""
    echo "❌ Setup failed. Please check the logs above."
fi

