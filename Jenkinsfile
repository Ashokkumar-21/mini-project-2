pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'
        AWS_CREDENTIALS = credentials('aws-credentials')
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKER_IMAGE = 'ashok2102/mini-2:latest'
        CLUSTER = 'mini2-cluster'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Login AWS Credentials') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'AWS_CREDENTIALS',
                                          usernameVariable: 'AWS_ACCESS_KEY_ID',
                                          passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh'''
                    echo '==> Identity check'
                    aws sts get-caller-identity

                    echo '==> Terraform Init'
                    terraform init -reconfigure

                    echo '==> Terraform Apply'
                    terraform apply -auto-approve
                    '''
                                          }
            }
        }

        stage('Configure kubectl for EKS') {
            steps {
                sh''''
                aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                aws configure set default.region $AWS_REGION
                aws eks update-kubeconfig --name $CLUSTER
                ''''
            }
        }

        stage('Build Docker Image & Push') {
            steps {
                script {
                    sh''''
                    echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
                    docker build -t $DOCKER_IMAGE .
                    docker tag $DOCKER_IMAGE $DOCKER_IMAGE
                    docker push $DOCKER_IMAGE
                    ''''
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh'''
                aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER
                kubectl apply -f deployment.yaml
                kubectl apply -f service.yaml
                '''
            }
        }
    }
}

