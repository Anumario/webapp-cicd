pipeline {
    agent any

    stages {
        stage('Clone Repo') {
            steps {
                git branch: 'main', url: 'https://github.com/Anumario/webapp-cicd.git'
            }
        }

        stage('Build Image') {
            steps {
                sh 'docker build -t webapp-cicd .'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'docker run --rm webapp-cicd npm test'
            }
        }

        stage('Run Container') {
            steps {
                // pour l'ancien conteneur (s'il existe) sans casser le pipeline
                sh 'docker stop webapp || true && docker rm webapp || true'
                
                // exécuter une nouvelle version
                sh 'docker run -d --name webapp -p 3000:3000 webapp-cicd'
            }
        }
    }
    post {
        always {
            archiveArtifacts artifacts: 'coverage/**', allowEmptyArchive: true
        }
    }

}

