pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'
        AWS_ACCOUNT_ID = '098588167308'
        IMAGE_TAG = 'v2'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t $ECR_REPO_NAME:$IMAGE_TAG .'
                }
            }
        }

        stage('Tag Image') {
            steps {
                script {
                    sh 'docker tag $ECR_REPO_NAME:$IMAGE_TAG $FULL_IMAGE_NAME'
                }
            }
        }
    }
}