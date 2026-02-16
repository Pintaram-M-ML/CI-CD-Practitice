# Fix Jenkins Docker Access

## 🔍 Problem

Your Jenkins pipeline is failing with:
```
docker: not found
```

This means Jenkins doesn't have access to Docker.

## ✅ Quick Fix (Recommended)

### Step 1: Find Your Jenkins Container Name

```bash
docker ps -a | grep jenkins
```

Example output:
```
abc123  jenkins/jenkins:lts  "jenkins"  jenkins
```

### Step 2: Install Docker CLI in Jenkins Container

```bash
# Replace 'jenkins' with your actual container name
JENKINS_CONTAINER=jenkins

# Enter the container as root
docker exec -it -u root $JENKINS_CONTAINER bash

# Inside the container, run:
apt-get update
apt-get install -y docker.io

# Add jenkins user to docker group
usermod -aG docker jenkins

# Exit the container
exit
```

### Step 3: Mount Docker Socket

```bash
# Stop Jenkins
docker stop $JENKINS_CONTAINER

# Restart with Docker socket mounted
docker run -d \
  --name jenkins-new \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --group-add $(stat -c '%g' /var/run/docker.sock) \
  jenkins/jenkins:lts

# Remove old container
docker rm $JENKINS_CONTAINER
```

### Step 4: Verify Docker Access

```bash
docker exec jenkins-new docker --version
```

You should see:
```
Docker version 24.x.x, build xxxxx
```

## 🚀 Alternative: Use Automated Script

```bash
# Make the script executable
chmod +x jenkins-docker-setup.sh

# Run the script
sudo ./jenkins-docker-setup.sh
```

## 🐳 If Using Docker Compose

Update your `docker-compose.yml`:

```yaml
version: '3.8'

services:
  jenkins:
    image: jenkins/jenkins:lts
    container_name: jenkins
    user: root
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - DOCKER_HOST=unix:///var/run/docker.sock

volumes:
  jenkins_home:
```

Then:
```bash
docker-compose down
docker-compose up -d

# Install Docker CLI
docker exec -u root jenkins bash -c "apt-get update && apt-get install -y docker.io"
docker restart jenkins
```

## ☸️ If Jenkins is Running in Kubernetes

You need to mount the Docker socket in your Jenkins pod:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: jenkins
spec:
  containers:
  - name: jenkins
    image: jenkins/jenkins:lts
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock
    - name: jenkins-home
      mountPath: /var/jenkins_home
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
      type: Socket
  - name: jenkins-home
    persistentVolumeClaim:
      claimName: jenkins-pvc
```

## 🧪 Test the Fix

After applying the fix, run this in Jenkins:

1. Go to **Manage Jenkins** → **Script Console**
2. Run:
   ```groovy
   println "docker version".execute().text
   ```

You should see Docker version information.

## 🔄 Re-run Your Pipeline

After fixing Docker access:

1. Go to your Jenkins job
2. Click **Build Now**
3. The pipeline should now proceed past the "Environment Info" stage

## 📝 Expected Output

After the fix, you should see:

```
+ docker --version
Docker version 24.0.7, build afdd53b
+ docker-compose --version
Docker Compose version v2.21.0
```

## ⚠️ Important Notes

1. **Security**: Mounting `/var/run/docker.sock` gives Jenkins full Docker access. Use with caution in production.

2. **Permissions**: The jenkins user needs to be in the docker group.

3. **Restart Required**: After adding jenkins to docker group, restart Jenkins:
   ```bash
   docker restart jenkins
   ```

## 🆘 Still Having Issues?

### Check Docker Socket Permissions

```bash
ls -la /var/run/docker.sock
```

Should show:
```
srw-rw---- 1 root docker 0 ... /var/run/docker.sock
```

### Check Jenkins User Groups

```bash
docker exec jenkins id jenkins
```

Should include `docker` group:
```
uid=1000(jenkins) gid=1000(jenkins) groups=1000(jenkins),999(docker)
```

### Check Docker Service

```bash
systemctl status docker
```

Should be `active (running)`.

## 📚 Next Steps

Once Docker is working:

1. ✅ Re-run your Jenkins pipeline
2. ✅ All stages should complete successfully
3. ✅ Images will be built and pushed to Docker Hub
4. ✅ Application will be deployed to Kubernetes

---

**Need help?** Check the Jenkins console output for specific error messages.

