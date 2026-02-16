# Jenkins Pipeline Quick Reference

## 🚀 Quick Start

### 1. Prerequisites Checklist

- [ ] Jenkins server running
- [ ] Docker installed on Jenkins
- [ ] kubectl configured
- [ ] Docker Hub credentials added to Jenkins
- [ ] Kubeconfig credentials added to Jenkins

### 2. Required Jenkins Credentials

| Credential ID | Type | Description |
|--------------|------|-------------|
| `dockerhub-credentials` | Username/Password | Docker Hub login |
| `kubeconfig-credentials` | Secret File | Kubernetes config file |

### 3. Environment Variables in Jenkinsfile

```groovy
DOCKER_USERNAME = 'pintaram369'          # Change to your Docker Hub username
K8S_NAMESPACE = 'default'                # Change to your namespace
APP_NAME = 'taskmanager'                 # Application name
```

## 📊 Pipeline Flow

```
┌─────────────┐
│  Checkout   │ ──> Clone repository
└──────┬──────┘
       │
┌──────▼──────┐
│   Install   │ ──> npm install
│Dependencies │
└──────┬──────┘
       │
┌──────▼──────┐
│  Run Tests  │ ──> npm test
└──────┬──────┘
       │
┌──────▼──────────────────────┐
│  Build Docker Images         │
│  ┌──────────────────────┐   │
│  │ Frontend (parallel)  │   │
│  │ Backend  (parallel)  │   │
│  │ Database (parallel)  │   │
│  └──────────────────────┘   │
└──────┬──────────────────────┘
       │
┌──────▼──────┐
│Security Scan│ ──> Trivy (optional)
└──────┬──────┘
       │
┌──────▼──────┐
│Push to Hub  │ ──> Docker Hub
└──────┬──────┘
       │
┌──────▼──────┐
│Update K8s   │ ──> Update YAML files
│ Manifests   │
└──────┬──────┘
       │
┌──────▼──────┐
│Deploy to K8s│ ──> kubectl apply
└──────┬──────┘
       │
┌──────▼──────┐
│Initialize DB│ ──> Run init.sql
└──────┬──────┘
       │
┌──────▼──────┐
│   Verify    │ ──> Check pods
└──────┬──────┘
       │
┌──────▼──────┐
│Health Check │ ──> Test API
└─────────────┘
```

## 🔧 Common Commands

### Trigger Build Manually
```bash
# Via Jenkins UI
Click "Build Now" button

# Via Jenkins CLI
java -jar jenkins-cli.jar -s http://jenkins-url/ build taskmanager-pipeline
```

### Check Build Status
```bash
# Get latest build status
curl http://jenkins-url/job/taskmanager-pipeline/lastBuild/api/json

# View console output
curl http://jenkins-url/job/taskmanager-pipeline/lastBuild/consoleText
```

### Verify Deployment
```bash
# Check pods
kubectl get pods -l app=taskmanager

# Check services
kubectl get svc -l app=taskmanager

# Check deployment status
kubectl rollout status deployment/taskmanager-backend
```

## 🐛 Troubleshooting

### Build Fails at Docker Build Stage

**Symptoms**: `docker: command not found` or permission denied

**Solution**:
```bash
# Add Jenkins user to docker group
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### Build Fails at Kubernetes Deploy Stage

**Symptoms**: `kubectl: command not found` or connection refused

**Solution**:
```bash
# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install kubectl /usr/local/bin/

# Verify kubeconfig
kubectl cluster-info
```

### Docker Push Fails

**Symptoms**: `denied: requested access to the resource is denied`

**Solution**:
1. Verify Docker Hub credentials in Jenkins
2. Check Docker Hub username matches in Jenkinsfile
3. Ensure you're logged in: `docker login`

### Database Not Initialized

**Symptoms**: `relation "tasks" does not exist`

**Solution**:
```bash
# Manually initialize database
kubectl exec -i deployment/taskmanager-db -- psql -U postgres -d taskmanager < database/init.sql
```

## 📝 Customization Examples

### Change Image Tag Strategy

**Use Git Commit SHA:**
```groovy
environment {
    IMAGE_TAG = "${env.GIT_COMMIT_SHORT}"
}
```

**Use Semantic Versioning:**
```groovy
environment {
    IMAGE_TAG = "v1.0.${env.BUILD_NUMBER}"
}
```

### Add Slack Notifications

```groovy
post {
    success {
        slackSend (
            color: 'good',
            message: "✅ Build Success: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
        )
    }
    failure {
        slackSend (
            color: 'danger',
            message: "❌ Build Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
        )
    }
}
```

### Add Approval Stage

```groovy
stage('Approve Deployment') {
    steps {
        input message: 'Deploy to production?', ok: 'Deploy'
    }
}
```

## 🔐 Security Checklist

- [ ] Use Docker Hub access tokens instead of passwords
- [ ] Use Kubernetes service accounts with limited permissions
- [ ] Store secrets in Kubernetes Secrets, not in code
- [ ] Enable security scanning (Trivy, Snyk)
- [ ] Use private Docker registry for production
- [ ] Implement RBAC in Kubernetes
- [ ] Rotate credentials regularly

## 📈 Performance Tips

1. **Use Docker Layer Caching**
   ```groovy
   docker.build("${IMAGE_NAME}", "--cache-from ${IMAGE_NAME}:latest .")
   ```

2. **Parallel Builds**
   - Already implemented for Docker image builds
   - Consider parallelizing tests

3. **Cleanup Old Images**
   - Implemented in `post.always` section
   - Keeps last 7 days of images

## 🎯 Best Practices

1. **Version Everything**
   - Tag images with build number
   - Keep `latest` tag for convenience

2. **Test Before Deploy**
   - Run unit tests
   - Run integration tests
   - Perform security scans

3. **Rollback Strategy**
   ```bash
   # Rollback to previous version
   kubectl rollout undo deployment/taskmanager-backend
   ```

4. **Monitor Deployments**
   - Check pod logs
   - Monitor resource usage
   - Set up alerts

## 📚 Additional Resources

- [Jenkinsfile Documentation](../Jenkinsfile)
- [Setup Guide](../JENKINS_SETUP.md)
- [Kubernetes Deployments](../README.md)

