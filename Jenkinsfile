pipeline {
    agent any

    environment {
        DOCKERHUB = "sgw105"
        IMAGE = "renegade-demo"
    }

    stages {
        stage("Clone") {
            steps {
                checkout scm
            }
        }

        stage("Build Docker Image") {
            steps {
                sh "docker build -t $DOCKERHUB/$IMAGE:latest ."
            }
        }

        stage("Push to DockerHub") {
            steps {
                withDockerRegistry([credentialsId: 'dockerhub', url: '']) {
                    sh "docker push $DOCKERHUB/$IMAGE:latest"
                }
            }
        }

        stage("Deploy to Kubernetes") {
            steps {
                sh "kubectl apply -f deployment.yaml"
                sh "kubectl rollout restart deployment renegade-demo"
            }
        }
    }
}
