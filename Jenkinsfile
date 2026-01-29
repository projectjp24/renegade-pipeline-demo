pipeline {
    agent any

    environment {
        DOCKERHUB = "sgw105"
        IMAGE = "renegade-demo"
        KUBE_DEPLOYMENT = "renegade-demo"
        KUBE_NAMESPACE = "default"
        KUBECONFIG = '/var/lib/jenkins/.kube/config'
    }

    options {
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
    }

    stages {

        stage("Clone Repository") {
            steps {
                ansiColor('xterm') {
                    echo "Cloning repository..."
                    checkout scm
                }
            }
        }

        stage("Build Docker Image") {
            steps {
                ansiColor('xterm') {
                    echo "Building Docker image: $DOCKERHUB/$IMAGE:latest"
                    sh """
                        docker build -t $DOCKERHUB/$IMAGE:latest .
                        echo "Docker images:"
                        docker images | grep $IMAGE || true
                    """
                }
            }
        }

        stage("Push to DockerHub") {
            steps {
                ansiColor('xterm') {
                    echo "Pushing image to DockerHub..."
                    withDockerRegistry([credentialsId: 'dockerhub', url: '']) {
                        sh "docker push $DOCKERHUB/$IMAGE:latest"
                    }
                }
            }
        }

        stage("Deploy to Kubernetes") {
            steps {
                ansiColor('xterm') {
                    echo "Applying Kubernetes manifest..."
                    sh """
                        kubectl apply -f deployment.yaml
                        kubectl rollout restart deployment/$KUBE_DEPLOYMENT -n $KUBE_NAMESPACE
                        kubectl rollout status deployment/$KUBE_DEPLOYMENT -n $KUBE_NAMESPACE
                        kubectl get pods -n $KUBE_NAMESPACE -o wide
                        kubectl get svc -n $KUBE_NAMESPACE -o wide
                    """
                }
            }
        }
    }

    post {
        always {
            ansiColor('xterm') {
                echo "Pipeline finished. Checking Docker images and Kubernetes resources..."
                sh "docker images | grep $IMAGE || true"
                sh "kubectl get all -n $KUBE_NAMESPACE"
            }
        }
        success {
            echo "✅ Deployment succeeded!"
        }
        failure {
            echo "❌ Deployment failed. Check logs above."
        }
    }
}
