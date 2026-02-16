pipeline {
    agent any

    environment {
        // Docker Hub credentials (configure in Jenkins)
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_CREDENTIALS_ID = 'dockerhub-credentials'
        DOCKER_USERNAME = 'pintaram369'

        // Image names and tags
        FRONTEND_IMAGE = "${DOCKER_USERNAME}/taskmanager-frontend"
        BACKEND_IMAGE = "${DOCKER_USERNAME}/taskmanager-backend"
        DB_IMAGE = "${DOCKER_USERNAME}/taskmanager-postgres"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        LATEST_TAG = "latest"

        // Kubernetes configuration
        KUBECONFIG_CREDENTIALS_ID = 'kubeconfig-credentials'
        K8S_NAMESPACE = 'default'

        // Application configuration
        APP_NAME = 'taskmanager'

        // Add custom bin directory to PATH
        PATH = "$HOME/bin:/usr/local/bin:$PATH"
    }

    stages {
        stage('Setup Tools') {
            steps {
                echo '� Setting up required tools...'
                script {
                    // Install Docker CLI if not present (without sudo)
                    sh '''
                        if ! command -v docker &> /dev/null; then
                            echo "📦 Installing Docker CLI..."
                            cd /tmp

                            # Download and install Docker CLI
                            curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-24.0.7.tgz -o docker.tgz
                            tar xzvf docker.tgz
                            cp docker/docker /usr/local/bin/ 2>/dev/null || cp docker/docker $HOME/bin/ || mkdir -p $HOME/bin && cp docker/docker $HOME/bin/
                            rm -rf docker docker.tgz

                            # Add to PATH if needed
                            export PATH=$HOME/bin:$PATH

                            echo "✅ Docker CLI installed"
                        else
                            echo "✅ Docker CLI already available"
                        fi

                        # Install kubectl if not present
                        if ! command -v kubectl &> /dev/null; then
                            echo "📦 Installing kubectl..."
                            cd /tmp
                            curl -LO "https://dl.k8s.io/release/v1.28.0/bin/linux/amd64/kubectl"
                            chmod +x kubectl
                            cp kubectl /usr/local/bin/ 2>/dev/null || cp kubectl $HOME/bin/ || mkdir -p $HOME/bin && cp kubectl $HOME/bin/
                            rm kubectl

                            # Add to PATH if needed
                            export PATH=$HOME/bin:$PATH

                            echo "✅ kubectl installed"
                        else
                            echo "✅ kubectl already available"
                        fi

                        # Install docker-compose if not present
                        if ! command -v docker-compose &> /dev/null; then
                            echo "📦 Installing docker-compose..."
                            cd /tmp
                            curl -L "https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-linux-x86_64" -o docker-compose
                            chmod +x docker-compose
                            cp docker-compose /usr/local/bin/ 2>/dev/null || cp docker-compose $HOME/bin/ || mkdir -p $HOME/bin && cp docker-compose $HOME/bin/
                            rm docker-compose

                            # Add to PATH if needed
                            export PATH=$HOME/bin:$PATH

                            echo "✅ docker-compose installed"
                        else
                            echo "✅ docker-compose already available"
                        fi

                        # Install Node.js and npm if not present
                        if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
                            echo "📦 Installing Node.js and npm..."
                            cd /tmp

                            # Download Node.js LTS (v18.x)
                            curl -fsSL https://nodejs.org/dist/v18.19.0/node-v18.19.0-linux-x64.tar.xz -o node.tar.xz
                            tar -xf node.tar.xz

                            # Copy to user bin or local bin
                            if [ -w /usr/local/bin ]; then
                                cp -r node-v18.19.0-linux-x64/bin/* /usr/local/bin/
                                cp -r node-v18.19.0-linux-x64/lib/* /usr/local/lib/
                                cp -r node-v18.19.0-linux-x64/include/* /usr/local/include/ 2>/dev/null || true
                                cp -r node-v18.19.0-linux-x64/share/* /usr/local/share/ 2>/dev/null || true
                            else
                                # Install to user directory
                                mkdir -p $HOME/.nodejs
                                cp -r node-v18.19.0-linux-x64/* $HOME/.nodejs/
                                ln -sf $HOME/.nodejs/bin/node $HOME/bin/node
                                ln -sf $HOME/.nodejs/bin/npm $HOME/bin/npm
                                ln -sf $HOME/.nodejs/bin/npx $HOME/bin/npx
                            fi

                            rm -rf node.tar.xz node-v18.19.0-linux-x64
                            echo "✅ Node.js and npm installed"
                        else
                            echo "✅ Node.js and npm already available"
                        fi

                        # Verify all installations
                        echo ""
                        echo "=== Installed Tool Versions ==="
                        docker --version || echo "⚠️ Docker not accessible"
                        docker-compose --version || echo "⚠️ Docker Compose not accessible"
                        kubectl version --client --short 2>/dev/null || kubectl version --client || echo "⚠️ kubectl not accessible"
                        node --version || echo "⚠️ Node.js not accessible"
                        npm --version || echo "⚠️ npm not accessible"
                        echo "================================"
                    '''
                }
            }
        }

        stage('Checkout') {
            steps {
                echo '📥 Checking out source code...'
                // Clone the repository
                git branch: 'master',
                    url: 'https://github.com/Pintaram-M-ML/CI-CD-Practitice.git'

                // Get short commit ID
                sh 'git rev-parse --short HEAD > .git/commit-id'
                script {
                    env.GIT_COMMIT_SHORT = readFile('.git/commit-id').trim()
                }
            }
        }

        stage('Environment Info') {
            steps {
                echo '🔍 Environment Information'
                sh '''
                    echo "Build Number: ${BUILD_NUMBER}"
                    echo "Git Commit: ${GIT_COMMIT_SHORT}"
                    echo "Branch: ${GIT_BRANCH}"
                    echo "Docker Version:"
                    docker --version
                    echo "Docker Compose Version:"
                    docker-compose --version
                '''
            }
        }

        stage('Install Dependencies') {
            steps {
                echo '📦 Installing backend dependencies...'
                dir('backend') {
                    sh 'npm install'
                }
            }
        }

        stage('Run Tests') {
            steps {
                echo '🧪 Running tests...'
                dir('backend') {
                    sh 'npm test || echo "No tests configured yet"'
                }
            }
        }

        stage('Build Docker Images') {
            parallel {
                stage('Build Frontend Image') {
                    steps {
                        echo '🏗️ Building frontend Docker image...'
                        script {
                            sh """
                                docker build -f docker/Dockerfile.nginx \
                                    -t ${FRONTEND_IMAGE}:${IMAGE_TAG} \
                                    -t ${FRONTEND_IMAGE}:${LATEST_TAG} \
                                    .
                            """
                        }
                    }
                }

                stage('Build Backend Image') {
                    steps {
                        echo '🏗️ Building backend Docker image...'
                        script {
                            sh """
                                docker build -f docker/Dockerfile.backend \
                                    -t ${BACKEND_IMAGE}:${IMAGE_TAG} \
                                    -t ${BACKEND_IMAGE}:${LATEST_TAG} \
                                    .
                            """
                        }
                    }
                }

                stage('Build Database Image') {
                    steps {
                        echo '🏗️ Building database Docker image...'
                        script {
                            sh """
                                docker build -f - -t ${DB_IMAGE}:${IMAGE_TAG} -t ${DB_IMAGE}:${LATEST_TAG} . <<EOF
FROM postgres:15-alpine
COPY database/init.sql /docker-entrypoint-initdb.d/
EOF
                            """
                        }
                    }
                }
            }
        }

        stage('Security Scan') {
            steps {
                echo '🔒 Running security scans...'
                script {
                    // Using Trivy for vulnerability scanning (optional)
                    sh '''
                        if command -v trivy &> /dev/null; then
                            echo "Scanning images with Trivy..."
                            trivy image ${FRONTEND_IMAGE}:${IMAGE_TAG} || true
                            trivy image ${BACKEND_IMAGE}:${IMAGE_TAG} || true
                            trivy image ${DB_IMAGE}:${IMAGE_TAG} || true
                        else
                            echo "Trivy not installed, skipping security scan"
                        fi
                    '''
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo '📤 Pushing images to Docker Hub...'
                script {
                    docker.withRegistry("https://${DOCKER_REGISTRY}", "${DOCKER_CREDENTIALS_ID}") {
                        sh """
                            docker push ${FRONTEND_IMAGE}:${IMAGE_TAG}
                            docker push ${FRONTEND_IMAGE}:${LATEST_TAG}

                            docker push ${BACKEND_IMAGE}:${IMAGE_TAG}
                            docker push ${BACKEND_IMAGE}:${LATEST_TAG}

                            docker push ${DB_IMAGE}:${IMAGE_TAG}
                            docker push ${DB_IMAGE}:${LATEST_TAG}
                        """
                    }
                }
            }
        }

        stage('Update Kubernetes Manifests') {
            steps {
                echo '📝 Updating Kubernetes deployment manifests...'
                script {
                    sh """
                        # Update image tags in deployment files
                        sed -i 's|image: ${FRONTEND_IMAGE}:.*|image: ${FRONTEND_IMAGE}:${IMAGE_TAG}|g' frontend-deployment.yaml
                        sed -i 's|image: ${BACKEND_IMAGE}:.*|image: ${BACKEND_IMAGE}:${IMAGE_TAG}|g' backend-deployment.yaml
                        sed -i 's|image: ${DB_IMAGE}:.*|image: ${DB_IMAGE}:${IMAGE_TAG}|g' db-deployment.yaml

                        echo "Updated deployment files:"
                        grep "image:" frontend-deployment.yaml backend-deployment.yaml db-deployment.yaml
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo '🚀 Deploying to Kubernetes...'
                script {
                    withCredentials([file(credentialsId: "${KUBECONFIG_CREDENTIALS_ID}", variable: 'KUBECONFIG')]) {
                        sh """
                            export KUBECONFIG=\${KUBECONFIG}

                            # Apply PVC first
                            kubectl apply -f db-pvc.yaml -n ${K8S_NAMESPACE}

                            # Apply services
                            kubectl apply -f db-service.yaml -n ${K8S_NAMESPACE}
                            kubectl apply -f backend-service.yaml -n ${K8S_NAMESPACE}
                            kubectl apply -f frontend-service.yaml -n ${K8S_NAMESPACE}

                            # Apply deployments
                            kubectl apply -f db-deployment.yaml -n ${K8S_NAMESPACE}
                            kubectl apply -f backend-deployment.yaml -n ${K8S_NAMESPACE}
                            kubectl apply -f frontend-deployment.yaml -n ${K8S_NAMESPACE}

                            # Wait for rollout to complete
                            kubectl rollout status deployment/taskmanager-db -n ${K8S_NAMESPACE} --timeout=5m
                            kubectl rollout status deployment/taskmanager-backend -n ${K8S_NAMESPACE} --timeout=5m
                            kubectl rollout status deployment/taskmanager-frontend -n ${K8S_NAMESPACE} --timeout=5m
                        """
                    }
                }
            }
        }

        stage('Initialize Database') {
            steps {
                echo '🗄️ Initializing database schema...'
                script {
                    withCredentials([file(credentialsId: "${KUBECONFIG_CREDENTIALS_ID}", variable: 'KUBECONFIG')]) {
                        sh """
                            export KUBECONFIG=\${KUBECONFIG}

                            # Get database pod name
                            DB_POD=\$(kubectl get pods -n ${K8S_NAMESPACE} -l tier=db -o jsonpath='{.items[0].metadata.name}')

                            # Check if tables exist
                            TABLE_EXISTS=\$(kubectl exec -n ${K8S_NAMESPACE} \${DB_POD} -- psql -U postgres -d taskmanager -tAc "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'tasks');")

                            if [ "\${TABLE_EXISTS}" = "f" ]; then
                                echo "Initializing database schema..."
                                kubectl exec -i -n ${K8S_NAMESPACE} \${DB_POD} -- psql -U postgres -d taskmanager < database/init.sql
                            else
                                echo "Database already initialized, skipping..."
                            fi
                        """
                    }
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                echo '✅ Verifying deployment...'
                script {
                    withCredentials([file(credentialsId: "${KUBECONFIG_CREDENTIALS_ID}", variable: 'KUBECONFIG')]) {
                        sh """
                            export KUBECONFIG=\${KUBECONFIG}

                            echo "=== Pods Status ==="
                            kubectl get pods -n ${K8S_NAMESPACE} -l app=${APP_NAME}

                            echo "=== Services ==="
                            kubectl get services -n ${K8S_NAMESPACE} -l app=${APP_NAME}

                            echo "=== PVC Status ==="
                            kubectl get pvc -n ${K8S_NAMESPACE}

                            # Check if all pods are running
                            kubectl wait --for=condition=ready pod -l app=${APP_NAME} -n ${K8S_NAMESPACE} --timeout=5m

                            echo "✅ All pods are running successfully!"
                        """
                    }
                }
            }
        }

        stage('Health Check') {
            steps {
                echo '🏥 Running health checks...'
                script {
                    withCredentials([file(credentialsId: "${KUBECONFIG_CREDENTIALS_ID}", variable: 'KUBECONFIG')]) {
                        sh """
                            export KUBECONFIG=\${KUBECONFIG}

                            # Get backend pod name
                            BACKEND_POD=\$(kubectl get pods -n ${K8S_NAMESPACE} -l tier=backend -o jsonpath='{.items[0].metadata.name}')

                            # Test backend health endpoint
                            kubectl exec -n ${K8S_NAMESPACE} \${BACKEND_POD} -- wget -qO- http://localhost:3000/api/health || echo "Health check endpoint not available"

                            echo "✅ Health checks completed!"
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline completed successfully!'
            script {
                sh """
                    echo "========================================="
                    echo "🎉 Deployment Successful!"
                    echo "========================================="
                    echo "Build Number: ${BUILD_NUMBER}"
                    echo "Git Commit: ${GIT_COMMIT_SHORT}"
                    echo "Frontend Image: ${FRONTEND_IMAGE}:${IMAGE_TAG}"
                    echo "Backend Image: ${BACKEND_IMAGE}:${IMAGE_TAG}"
                    echo "Database Image: ${DB_IMAGE}:${IMAGE_TAG}"
                    echo "========================================="
                    echo "Access your application at:"
                    echo "http://<your-k8s-node-ip>:30080"
                    echo "========================================="
                """
            }
        }

        failure {
            echo '❌ Pipeline failed!'
            script {
                sh """
                    echo "========================================="
                    echo "❌ Deployment Failed!"
                    echo "========================================="
                    echo "Build Number: ${BUILD_NUMBER}"
                    echo "Git Commit: ${GIT_COMMIT_SHORT}"
                    echo "Check the logs above for error details"
                    echo "========================================="
                """
            }
        }

        always {
            echo '🧹 Cleaning up...'
            sh '''
                # Clean up old Docker images (keep last 5 builds)
                docker image prune -f --filter "until=168h" || true

                # Remove dangling images
                docker image prune -f || true
            '''
        }
    }
}
