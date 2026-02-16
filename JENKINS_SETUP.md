# Jenkins CI/CD Pipeline Setup Guide

This guide will help you set up Jenkins CI/CD pipeline for the Task Manager application.

## 📋 Prerequisites

- Jenkins server installed and running
- Docker installed on Jenkins server
- kubectl installed on Jenkins server
- Access to Kubernetes cluster
- Docker Hub account

## 🔧 Jenkins Configuration

### 1. Install Required Jenkins Plugins

Go to **Manage Jenkins** → **Manage Plugins** → **Available** and install:

- **Docker Pipeline** - For Docker operations
- **Kubernetes CLI** - For kubectl commands
- **Git** - For source code management
- **Pipeline** - For pipeline support
- **Credentials Binding** - For secure credential management

### 2. Configure Docker Hub Credentials

1. Go to **Manage Jenkins** → **Manage Credentials**
2. Click on **(global)** domain
3. Click **Add Credentials**
4. Select **Username with password**
5. Configure:
   - **Username**: Your Docker Hub username (e.g., `pintaram369`)
   - **Password**: Your Docker Hub password or access token
   - **ID**: `dockerhub-credentials`
   - **Description**: Docker Hub Credentials
6. Click **OK**

### 3. Configure Kubernetes Credentials

#### Option A: Using kubeconfig file

1. Go to **Manage Jenkins** → **Manage Credentials**
2. Click **Add Credentials**
3. Select **Secret file**
4. Configure:
   - **File**: Upload your `~/.kube/config` file
   - **ID**: `kubeconfig-credentials`
   - **Description**: Kubernetes Config
5. Click **OK**

#### Option B: Using Service Account Token (Recommended for production)

```bash
# Create service account
kubectl create serviceaccount jenkins -n default

# Create cluster role binding
kubectl create clusterrolebinding jenkins-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=default:jenkins

# Get the token
kubectl create token jenkins -n default --duration=87600h
```

Then in Jenkins:
1. Add **Secret text** credential
2. Paste the token
3. ID: `k8s-token`

### 4. Configure Jenkins Pipeline Job

1. Click **New Item**
2. Enter name: `taskmanager-pipeline`
3. Select **Pipeline**
4. Click **OK**

#### Configure Pipeline:

**General:**
- ✅ GitHub project (optional): `https://github.com/yourusername/taskmanager`

**Build Triggers:**
- ✅ Poll SCM: `H/5 * * * *` (check every 5 minutes)
- OR ✅ GitHub hook trigger for GITScm polling (for webhooks)

**Pipeline:**
- **Definition**: Pipeline script from SCM
- **SCM**: Git
- **Repository URL**: Your Git repository URL
- **Credentials**: Add your Git credentials if private
- **Branch**: `*/main` or `*/master`
- **Script Path**: `Jenkinsfile`

Click **Save**

## 🚀 Pipeline Stages Overview

The Jenkinsfile includes the following stages:

1. **Checkout** - Clone the repository
2. **Environment Info** - Display build information
3. **Install Dependencies** - Install Node.js dependencies
4. **Run Tests** - Execute unit tests
5. **Build Docker Images** - Build frontend, backend, and database images (parallel)
6. **Security Scan** - Scan images for vulnerabilities (optional)
7. **Push to Docker Hub** - Push images to Docker registry
8. **Update Kubernetes Manifests** - Update image tags in YAML files
9. **Deploy to Kubernetes** - Apply Kubernetes resources
10. **Initialize Database** - Run database initialization script
11. **Verify Deployment** - Check pod status
12. **Health Check** - Test application endpoints

## 🔐 Security Best Practices

### 1. Use Docker Hub Access Tokens

Instead of using your password, create an access token:

1. Log in to Docker Hub
2. Go to **Account Settings** → **Security**
3. Click **New Access Token**
4. Name: `jenkins-ci`
5. Copy the token and use it as password in Jenkins credentials

### 2. Use Kubernetes Service Account

For production, use a dedicated service account with limited permissions:

```bash
# Create namespace
kubectl create namespace taskmanager

# Create service account
kubectl create serviceaccount jenkins-deployer -n taskmanager

# Create role with limited permissions
kubectl create role deployer \
  --verb=get,list,watch,create,update,patch,delete \
  --resource=deployments,services,pods,persistentvolumeclaims \
  -n taskmanager

# Bind role to service account
kubectl create rolebinding jenkins-deployer-binding \
  --role=deployer \
  --serviceaccount=taskmanager:jenkins-deployer \
  -n taskmanager
```

### 3. Store Sensitive Data in Kubernetes Secrets

Instead of hardcoding database passwords, use Kubernetes secrets:

```bash
kubectl create secret generic db-credentials \
  --from-literal=POSTGRES_PASSWORD=your-secure-password \
  -n taskmanager
```

## 📝 Customization

### Change Docker Hub Username

Edit the `Jenkinsfile` and update:

```groovy
environment {
    DOCKER_USERNAME = 'your-dockerhub-username'
}
```

### Change Kubernetes Namespace

Edit the `Jenkinsfile` and update:

```groovy
environment {
    K8S_NAMESPACE = 'your-namespace'
}
```

### Add Email Notifications

Add to the `post` section in Jenkinsfile:

```groovy
post {
    success {
        emailext (
            subject: "✅ Build Success: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            body: "The build completed successfully!",
            to: "your-email@example.com"
        )
    }
    failure {
        emailext (
            subject: "❌ Build Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            body: "The build failed. Check console output.",
            to: "your-email@example.com"
        )
    }
}
```

## 🧪 Testing the Pipeline

### 1. Manual Trigger

1. Go to your Jenkins job
2. Click **Build Now**
3. Watch the pipeline execution in **Console Output**

### 2. Git Push Trigger

```bash
# Make a change
echo "# Test" >> README.md
git add README.md
git commit -m "Test Jenkins pipeline"
git push origin main
```

Jenkins will automatically detect the change and trigger the build.

## 📊 Monitoring

### View Build History

- Go to your Jenkins job
- Click on build number (e.g., #1, #2)
- View **Console Output** for detailed logs

### Check Kubernetes Deployment

```bash
# Check pods
kubectl get pods -n default

# Check services
kubectl get services -n default

# View logs
kubectl logs -f deployment/taskmanager-backend -n default
```

## 🐛 Troubleshooting

### Issue: Docker permission denied

**Solution**: Add Jenkins user to docker group:
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### Issue: kubectl command not found

**Solution**: Install kubectl on Jenkins server:
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

### Issue: Cannot connect to Kubernetes cluster

**Solution**: Verify kubeconfig:
```bash
kubectl cluster-info
kubectl get nodes
```

## 📚 Additional Resources

- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Docker Pipeline Plugin](https://plugins.jenkins.io/docker-workflow/)
- [Kubernetes CLI Plugin](https://plugins.jenkins.io/kubernetes-cli/)
- [Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)

## 🎯 Next Steps

1. Set up automated testing
2. Add code quality checks (SonarQube)
3. Implement blue-green deployment
4. Add Slack/Teams notifications
5. Set up monitoring with Prometheus/Grafana

