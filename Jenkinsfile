pipeline {
    agent any

    environment {
        APP_NAME = "daniels-vulnerable-app"
        REPORT_DIR = "reports"
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
                docker build -t ${APP_NAME} .
                '''
            }
        }

        stage('Semgrep Scan') {
            steps {
                catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                    sh '''
                    mkdir -p ${REPORT_DIR}
                    semgrep scan --config p/owasp-top-ten --error . \
                        --json > ${REPORT_DIR}/semgrep.json
                    '''
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                    sh '''
                    mkdir -p ${REPORT_DIR}
                    trivy image --severity HIGH,CRITICAL --exit-code 1 \
                        --format json -o ${REPORT_DIR}/trivy.json ${APP_NAME}
                    '''
                }
            }
        }

        stage('Gitleaks Scan') {
            steps {
                catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                    sh '''
                    mkdir -p ${REPORT_DIR}
                    docker run --rm -v $(pwd):/path zricethezav/gitleaks:latest \
                        detect --source=/path --report-path=/path/${REPORT_DIR}/gitleaks.json --no-banner
                    '''
                }
            }
        }

        stage('Run App Container') {
            steps {
                catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                    sh '''
                    echo "Starting vulnerable app..."
                    docker stop d-vul-app || true
                    docker rm d-vul-app || true
                    docker run -d --name d-vul-app -p 3000:3000 ${APP_NAME}
                    sleep 5
                    '''
                }
            }
        }

        stage('ZAP Baseline Scan') {
            steps {
                catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                    sh '''
                    mkdir -p ${REPORT_DIR}
                    docker run --network="host" -u root \
                        -v $(pwd)/${REPORT_DIR}:/zap/wrk \
                        zaproxy/zap-stable zap-full-scan.py \
                        -t http://127.0.0.1:3000 \
                        -r zap-report.html
                    '''
                }
            }
        }

        stage('Archive Reports') {
            steps {
                archiveArtifacts artifacts: 'reports/*', fingerprint: true
            }
        }

        stage('Security Gate') {
            steps {
                script {
                    def failedStages = currentBuild.rawBuild.getActions(hudson.tasks.junit.TestResultAction)
                    echo "Security gate reached — evaluating scanner results."

                    // Jenkins marks stages with FAILURE if catchError triggered
                    if (currentBuild.result == 'FAILURE') {
                        error("Security gate: One or more scanners reported vulnerabilities. Build failed.")
                    }
                }
            }
        }
    }
}
