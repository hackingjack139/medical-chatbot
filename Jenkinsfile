pipeline {
    agent any

    environment {
        FRONTEND_IMAGE = "hackingjack139/medical-chatbot-frontend"
        BACKEND_IMAGE = "hackingjack139/medical-chatbot-backend"
        ML_IMAGE = "hackingjack139/medical-chatbot-ml"
        DOCKER_BUILDKIT = "1"
        COMPOSE_DOCKER_CLI_BUILD = "1"
        DOCKERHUB_USERNAME = credentials('dockerhub-username')
        DOCKERHUB_TOKEN = credentials('dockerhub-token')
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

        stage('Build Docker Images') {
            steps {
                sh "docker build -t ${FRONTEND_IMAGE}:latest ./frontend"
                sh "docker build -t ${BACKEND_IMAGE}:latest ./backend"
                sh "docker build -t ${ML_IMAGE}:latest ./ml-model"
            }
        }

        stage('ML Smoke Test') {
            steps {
                sh "docker run --rm ${ML_IMAGE}:latest python -m unittest test_app.py"
            }
        }

        stage('Push Docker Images') {
            steps {
                sh 'echo "$DOCKERHUB_TOKEN" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin'
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
                sh '''
                    docker run --rm \
                      -v "$PWD:/workspace" \
                      -v /var/run/docker.sock:/var/run/docker.sock \
                      -w /workspace/ansible \
                      python:3.12-slim sh -c "
                        pip install --no-cache-dir ansible && \
                        ansible-playbook playbook.yml
                      "
                '''
            }
        }
    }

    post {
        always {
            sh 'command -v docker >/dev/null 2>&1 && docker logout || true'
            cleanWs()
        }
    }
}
