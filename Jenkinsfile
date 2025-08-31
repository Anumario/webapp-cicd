pipeline {
    agent any

    environment {
        IMAGE   = "ghcr.io/anumario/webapp-cicd"  
        VERSION = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Anumario/webapp-cicd.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE}:${VERSION} -t ${IMAGE}:latest ."
            }
        }

        stage('Run Tests') {
            steps {
                sh "docker run --rm ${IMAGE}:${VERSION} npm test"
            }
        }

        stage('Push to GHCR') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'ghcr-creds', usernameVariable: 'GHCR_USER', passwordVariable: 'GHCR_PAT')]) {
                    sh '''
                        echo "$GHCR_PAT" | docker login ghcr.io -u "$GHCR_USER" --password-stdin
                        docker push ${IMAGE}:${VERSION}
                        docker push ${IMAGE}:latest
                        docker logout ghcr.io || true
                    '''
                }
            }
        }

        stage('Run Container (local)') {
            steps {
                sh 'docker stop webapp || true'
                sh 'docker rm webapp || true'
                sh "docker run -d --name webapp -p 3000:3000 ${IMAGE}:${VERSION}"
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'coverage/**', allowEmptyArchive: true
        }
    }
}

