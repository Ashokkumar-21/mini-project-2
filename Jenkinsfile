pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'
        IAM_ROLE_ARN = 'arn:aws:iam::098588167308:user/akcli'
        DOCKERHUB_IMAGE = 'ashok2102/mini-2:latest'
        CLUSTER = 'mini2-cluster'
    }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Build Image') {
            steps {
                sh 'docker build -t $DOCKERHUB_IMAGE .'
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials',
                                                  usernameVariable: 'DOCKER_USER',
                                                  passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
            docker tag $DOCKERHUB_IMAGE $DOCKERHUB_IMAGE
            docker push $DOCKERHUB_IMAGE
          '''
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-credentials',
                                                  usernameVariable: 'AWS_ACCESS_KEY_ID',
                                                  passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh '''
            aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER
            kubectl apply -f deployment.yaml
            kubectl apply -f service.yaml
          '''
                }
            }
        }
    }
}
