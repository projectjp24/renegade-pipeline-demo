pipeline {
    agent any

    environment {
        DOCKERHUB = "sgw105"
        IMAGE = "renegade-demo"
        KUBE_DEPLOYMENT = "renegade-demo"
        KUBE_NAMESPACE = "default"
    }

    options {
        ansiColor('xterm')   // colored console output
        timestamps()         // show timestamps
        timeout(time: 30, unit: 'MINUTES')  // fail if pipeline hangs
    }

    stages {

        stage("Clone Repository") {
            steps {
                echo "Cloning repository..."
                checkout scm
            }
        }

        stage("Build Docker Image") {
            steps {
                echo "Building Docker image: $DOCKERHUB/$IMAGE:latest"
                sh """
                    docker build -t $DOCKERHUB/$IMAGE:latest .
                    echo "Docker images:"
                    docker images | grep $IMAGE || true
                """
            }
        }

        stage("Push to DockerHub") {
            steps {
                echo "Pushing image to DockerHub..."
                withDockerRegistry([credentialsId: 'dockerhub', url: '']) {
                    sh """
                        docker push $DOCKERHUB/$IMAGE:latest
                    """
                }
            }
        }

        stage("Deploy to Kubernetes") {
            steps {
                echo "Applying Kubernetes manifest..."
                sh """
                    kubectl apply -f deployment.yaml
                    echo "Restarting deployment: $KUBE_DEPLOYMENT"
                    kubectl rollout restart deployment/$KUBE_DEPLOYMENT -n $KUBE_NAMESPACE
                    echo "Waiting for rollout to complete..."
                    kubectl rollout status deployment/$KUBE_DEPLOYMENT -n $KUBE_NAMESPACE
                    echo "Current pods:"
                    kubectl get pods -n $KUBE_NAMESPACE -o wide
                    echo "Services:"
                    kubectl get svc -n $KUBE_NAMESPACE -o wide
                """
            }
        }
    }

    post {
        always {
            echo "Pipeline finished. Checking current Docker images and Kubernetes resources..."
            sh "docker images | grep $IMAGE || true"
            sh "kubectl get all -n $KUBE_NAMESPACE"
        }
        success {
            echo "✅ Deployment succeeded!"
        }
        failure {
            echo "❌ Deployment failed. Check logs above for errors."
        }
    }
}
