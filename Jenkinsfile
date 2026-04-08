pipeline {
    agent any

    environment {
        APP_NAME = "daniel's-vulnerable-app"
        IMAGE_NAME = "daniel's-vulnerable-app"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/baselineOverride/DevSecOps---KAIDO.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                echo "Building Docker image..."
                docker build -t ${IMAGE_NAME} .
                '''
            }
        }

        stage('Trivy Scan') {
            steps {
                sh '''
                echo "Running Trivy scan..."
                trivy image --exit-code 0 --severity HIGH,CRITICAL ${IMAGE_NAME} > trivy-report.txt
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'trivy-report.txt'
                }
            }
        }

        stage('Semgrep Scan') {
            steps {
                sh '''
                echo "Running Semgrep scan..."
                semgrep scan --config auto . > semgrep-report.txt || true
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'semgrep-report.txt'
                }
            }
        }

        stage('Checkov Scan') {
            steps {
                sh '''
                echo "Running Checkov scan..."
                checkov -d . --output json > checkov-report.json || true
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'checkov-report.json'
                }
            }
        }

        stage('Gitleaks Scan') {
            steps {
                sh '''
                echo "Running Gitleaks scan (Docker)..."
                docker run --rm -v $(pwd):/path zricethezav/gitleaks:latest detect \
                    --source=/path \
                    --report-path=/path/gitleaks-report.json \
                    --no-banner || true
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'gitleaks-report.json'
                }
            }
        }

        stage('Run App Container') {
            steps {
                sh '''
                echo "Starting app container..."
                docker run -d --name d-vul-app -p 3000:3000 ${IMAGE_NAME}
                sleep 5
                '''
            }
        }

        stage('ZAP Baseline Scan') {
            steps {
                sh '''
                echo "Running ZAP baseline scan (Docker)..."
                docker run -v $(pwd):/zap/wrk/:rw -t zaproxy/zap-stable zap.sh \
                    -cmd -quickurl http://host.docker.internal:3000 \
                    -quickout /zap/wrk/zap-report.html || true
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'zap-report.html'
                }
            }
        }
    }

    post {
        always {
            sh '''
            echo "Cleaning up containers..."
            docker stop d-vul-app || true
            docker rm d-vul-app || true
            '''
        }
    }
}
