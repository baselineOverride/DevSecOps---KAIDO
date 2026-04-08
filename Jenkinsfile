pipeline {
    agent any

    environment {
        APP_NAME = "daniels-vulnerable-app"
        IMAGE_NAME = "daniels-vulnerable-app"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/baselineOverride/DevSecOps---KAIDO.git'
            }
        }

        stage('Install Security Tools') {
            steps {
                sh '''
                echo "Installing Semgrep & Checkov..."
                pip install --upgrade pip
                pip install semgrep checkov
                '''
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
                    archiveArtifacts artifacts: 'trivy-report.txt', allowEmptyArchive: true
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
                    archiveArtifacts artifacts: 'semgrep-report.txt', allowEmptyArchive: true
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
                    archiveArtifacts artifacts: 'checkov-report.json', allowEmptyArchive: true
                }
            }
        }

        stage('Gitleaks Scan') {
            steps {
                sh '''
                echo "Running Gitleaks scan..."
                docker run --rm -v $(pwd):/path zricethezav/gitleaks:latest detect \
                    --source=/path \
                    --report-path=/path/gitleaks-report.json \
                    --no-banner || true
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'gitleaks-report.json', allowEmptyArchive: true
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
                echo "Running ZAP baseline scan..."
                docker run \
                    -v $(pwd):/zap/wrk \
                    -u root \
                    zaproxy/zap-stable zap.sh \
                    -cmd \
                    -quickurl http://host.docker.internal:3000 \
                    -quickout /zap/wrk/zap-report.html || true
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'zap-report.html', allowEmptyArchive: true
                }
            }
        }
    }

    post {
        always {
            script {
                sh '''
                echo "Cleaning up containers..."
                docker stop d-vul-app || true
                docker rm d-vul-app || true
                '''
            }
        }
    }
}
