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
            agent {
                docker {
                    image 'node:20-alpine'
                    reuseNode true
                }
            }
            steps {
                dir('frontend') {
                    sh 'npm ci'
                    sh 'CI=true npm test -- --watchAll=false'
                }
            }
        }

        stage('Backend Test') {
            agent {
                docker {
                    image 'maven:3.9.9-eclipse-temurin-21'
                    reuseNode true
                }
            }
            steps {
                dir('backend') {
                    sh 'chmod +x mvnw'
                    sh './mvnw test'
                }
            }
        }

        stage('ML Smoke Test') {
            agent {
                docker {
                    image 'python:3.12-slim'
                    reuseNode true
                }
            }
            steps {
                dir('ml-model') {
                    sh '''
                        pip install --upgrade pip
                        pip install -r requirements.txt
                        python -m unittest test_app.py
                    '''
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                sh "docker build -t ${FRONTEND_IMAGE}:${IMAGE_TAG} -t ${FRONTEND_IMAGE}:latest ./frontend"
                sh "docker build -t ${BACKEND_IMAGE}:${IMAGE_TAG} -t ${BACKEND_IMAGE}:latest ./backend"
                sh "docker build -t ${ML_IMAGE}:${IMAGE_TAG} -t ${ML_IMAGE}:latest ./ml-model"
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
            sh 'command -v docker >/dev/null 2>&1 && docker compose down || true'
            sh 'command -v docker >/dev/null 2>&1 && docker logout || true'
            cleanWs()
        }
    }
}
