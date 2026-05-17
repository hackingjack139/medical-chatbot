pipeline {
    agent any

    parameters {
        choice(name: 'DEPLOY_TARGET', choices: ['compose', 'kubernetes'], description: 'Deployment target for this pipeline run')
    }

    environment {
        FRONTEND_IMAGE = "hackingjack139/medical-chatbot-frontend"
        BACKEND_IMAGE = "hackingjack139/medical-chatbot-backend"
        ML_IMAGE = "hackingjack139/medical-chatbot-ml"
        DOCKER_BUILDKIT = "1"
        COMPOSE_DOCKER_CLI_BUILD = "1"
        DOCKERHUB_USERNAME = credentials('dockerhub-username')
        DOCKERHUB_TOKEN = credentials('dockerhub-token')
        VAULT_TOKEN = credentials('vault-token')
    }

    options {
        timestamps()
    }

    stages {
        stage('Prepare Metadata') {
            steps {
                script {
                    env.IMAGE_TAG = env.GIT_COMMIT ? env.GIT_COMMIT.take(7) : "build-${env.BUILD_NUMBER}"
                }
            }
        }

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
                sh "docker build -t ${FRONTEND_IMAGE}:latest -t ${FRONTEND_IMAGE}:${IMAGE_TAG} ./frontend"
                sh "docker build -t ${BACKEND_IMAGE}:latest -t ${BACKEND_IMAGE}:${IMAGE_TAG} ./backend"
                sh "docker build -t ${ML_IMAGE}:latest -t ${ML_IMAGE}:${IMAGE_TAG} ./ml-model"
            }
        }

        stage('ML Smoke Test') {
            steps {
                sh "docker run --rm ${ML_IMAGE}:${IMAGE_TAG} python -m unittest test_app.py"
            }
        }

        stage('Security Scan') {
            steps {
                sh '''
                    set -eu
                    for image in \
                      "${FRONTEND_IMAGE}:${IMAGE_TAG}" \
                      "${BACKEND_IMAGE}:${IMAGE_TAG}" \
                      "${ML_IMAGE}:${IMAGE_TAG}"; do
                      echo "Scanning ${image}"
                      docker run --rm \
                        -v /var/run/docker.sock:/var/run/docker.sock \
                        aquasec/trivy:0.54.1 image \
                        --severity HIGH,CRITICAL \
                        --ignore-unfixed \
                        --exit-code 0 \
                        "${image}"
                    done
                '''
            }
        }

        stage('Push Docker Images') {
            steps {
                sh 'echo "$DOCKERHUB_TOKEN" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin'
                sh "docker push ${FRONTEND_IMAGE}:latest"
                sh "docker push ${FRONTEND_IMAGE}:${IMAGE_TAG}"
                sh "docker push ${BACKEND_IMAGE}:latest"
                sh "docker push ${BACKEND_IMAGE}:${IMAGE_TAG}"
                sh "docker push ${ML_IMAGE}:latest"
                sh "docker push ${ML_IMAGE}:${IMAGE_TAG}"
            }
        }

        stage('Deploy To Kubernetes') {
            when {
                expression { return fileExists('k8s/deploy.sh') }
            }
            steps {
                script {
                    int clusterReady = sh(
                        returnStatus: true,
                        script: 'command -v kubectl >/dev/null 2>&1 && kubectl cluster-info >/dev/null 2>&1'
                    )

                    if (env.DEPLOY_TARGET == 'kubernetes' && clusterReady == 0) {
                        sh 'chmod +x k8s/deploy.sh'
                        sh 'chmod +x k8s/verify.sh'
                        sh './k8s/deploy.sh "$IMAGE_TAG"'
                    } else if (env.DEPLOY_TARGET == 'kubernetes') {
                        error('Kubernetes deployment selected, but kubectl or cluster access is unavailable.')
                    } else {
                        echo "Skipping Kubernetes deploy because DEPLOY_TARGET=${env.DEPLOY_TARGET}"
                    }
                }
            }
        }

        stage('Deploy With Docker Compose') {
            when {
                expression { return fileExists('docker-compose.deploy.yml') && env.DEPLOY_TARGET == 'compose' }
            }
            steps {
                dir('ansible') {
                    sh 'VAULT_DEV_ROOT_TOKEN_ID="$VAULT_TOKEN" ansible-playbook playbook.yml -e app_image_tag=$IMAGE_TAG'
                }
            }
        }

        stage('Post-Deploy Verify') {
            when {
                expression { return fileExists('docker-compose.deploy.yml') || fileExists('k8s/deploy.sh') }
            }
            steps {
                script {
                    if (env.DEPLOY_TARGET == 'kubernetes') {
                        sh './k8s/verify.sh medical-chatbot'
                    } else {
                        dir('ansible') {
                            sh '''
                            set -eu
                            for i in $(seq 1 20); do
                              if curl -fsS http://localhost:3000 >/dev/null \
                                && curl -fsS http://localhost:8081/api/status >/dev/null \
                                && curl -fsS http://localhost:8000/ >/dev/null; then
                                exit 0
                              fi
                              sleep 3
                            done
                            PREVIOUS_TAG=$(awk -F= '/^APP_IMAGE_TAG=/{print $2}' /tmp/medical-chatbot-deploy/.env.previous 2>/dev/null || true)
                            if [ -n "${PREVIOUS_TAG}" ]; then
                              echo "Verification failed. Rolling back compose deployment to ${PREVIOUS_TAG}"
                              VAULT_DEV_ROOT_TOKEN_ID="$VAULT_TOKEN" ansible-playbook playbook.yml -e app_image_tag="${PREVIOUS_TAG}" || true
                            fi
                            echo "Post-deploy verification failed"
                            exit 1
                        '''
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                if (getContext(hudson.FilePath)) {
                    sh 'command -v docker >/dev/null 2>&1 && docker logout || true'
                    cleanWs()
                } else {
                    echo 'Skipping workspace cleanup because no FilePath context is available.'
                }
            }
        }
    }
}
