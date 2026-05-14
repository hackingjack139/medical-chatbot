pipeline {
    agent any

    environment {
        FRONTEND_IMAGE = "hackingjack139/medical-chatbot-frontend"
        BACKEND_IMAGE = "hackingjack139/medical-chatbot-backend"
        ML_IMAGE = "hackingjack139/medical-chatbot-ml"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        DOCKER_BUILDKIT = "1"
        COMPOSE_DOCKER_CLI_BUILD = "1"
    }

    options {
        timestamps()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Frontend Test') {
            steps {
                dir('frontend') {
                    sh 'npm ci'
                    sh 'CI=true npm test -- --watchAll=false'
                }
            }
        }

        stage('Backend Test') {
            steps {
                dir('backend') {
                    sh 'chmod +x mvnw'
                    sh './mvnw test'
                }
            }
        }

        stage('ML Smoke Test') {
            steps {
                dir('ml-model') {
                    sh '''
                        python3 -m venv .venv
                        . .venv/bin/activate
                        pip install --upgrade pip
                        pip install -r requirements.txt
                        python -m unittest test_app.py
                    '''
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                sh 'docker compose build'
                sh "docker tag \$(docker compose images -q frontend) ${FRONTEND_IMAGE}:${IMAGE_TAG}"
                sh "docker tag \$(docker compose images -q backend) ${BACKEND_IMAGE}:${IMAGE_TAG}"
                sh "docker tag \$(docker compose images -q ml-model) ${ML_IMAGE}:${IMAGE_TAG}"
                sh "docker tag \$(docker compose images -q frontend) ${FRONTEND_IMAGE}:latest"
                sh "docker tag \$(docker compose images -q backend) ${BACKEND_IMAGE}:latest"
                sh "docker tag \$(docker compose images -q ml-model) ${ML_IMAGE}:latest"
            }
        }

        stage('Push Docker Images') {
            when {
                expression { return env.DOCKERHUB_USERNAME?.trim() && env.DOCKERHUB_TOKEN?.trim() }
            }
            steps {
                sh 'echo "$DOCKERHUB_TOKEN" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin'
                sh "docker push ${FRONTEND_IMAGE}:${IMAGE_TAG}"
                sh "docker push ${BACKEND_IMAGE}:${IMAGE_TAG}"
                sh "docker push ${ML_IMAGE}:${IMAGE_TAG}"
                sh "docker push ${FRONTEND_IMAGE}:latest"
                sh "docker push ${BACKEND_IMAGE}:latest"
                sh "docker push ${ML_IMAGE}:latest"
            }
        }

        stage('Deploy With Docker Compose') {
            when {
                expression { return fileExists('docker-compose.deploy.yml') }
            }
            steps {
                sh 'docker compose -f docker-compose.deploy.yml up -d'
            }
        }
    }

    post {
        always {
            sh 'docker compose down || true'
            sh 'docker logout || true'
            cleanWs()
        }
    }
}
