pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'
        DOCKER_IMAGE = 'ashok2102/mini-2:latest'
        CLUSTER = 'mini2-cluster'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Login AWS & Terraform Apply') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-credentials',
                                                  usernameVariable: 'AWS_ACCESS_KEY_ID',
                                                  passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh '''
                    echo "==> AWS Identity check"
                    aws sts get-caller-identity

                    echo "==> Terraform Init"
                    terraform init -reconfigure

                    echo "==> Terraform Apply"
                    terraform apply -auto-approve
                    '''
                }
            }
        }

        stage('Configure kubectl for EKS') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-credentials',
                                                  usernameVariable: 'AWS_ACCESS_KEY_ID',
                                                  passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh '''
                    aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                    aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                    aws configure set default.region $AWS_REGION
                    aws eks update-kubeconfig --name $CLUSTER --region $AWS_REGION
                    '''
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials',
                                                  usernameVariable: 'DOCKER_USER',
                                                  passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    docker build -t $DOCKER_IMAGE .
                    docker push $DOCKER_IMAGE
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
