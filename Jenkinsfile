pipeline {
    agent any

    environment {
        APP_NAME = "daniels-vulnerable-app"
        IMAGE_NAME = "daniels-vulnerable-app"
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
                trivy image --exit-code 1 --severity HIGH,CRITICAL ${IMAGE_NAME} > trivy-report.txt
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'trivy-report.txt', allowEmptyArchive: true
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
                echo "Removing standing app containers..."
                docker stop d-vul-app || true
                docker rm d-vul-app || true

                echo "Starting app container..."
                docker run -d --name d-vul-app -p 3000:3000 daniels-vulnerable-app
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
                    -quickurl http://172.17.0.1:3000 \
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

}
