pipeline {
    agent any

    environment {
        IMAGE = "anumario/webapp-cicd"   // troque pelo seu Docker Hub ou GHCR
        VERSION = "${env.BUILD_NUMBER}"  // número de build do Jenkins
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

        stage('Run Container') {
            steps {
                // pour l'ancien conteneur (s'il existe) sans casser le pipeline
                sh 'docker stop webapp || true'
                sh 'docker rm webapp || true'

                // Téléchargez toujours la version nouvellement construite
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
  

               

