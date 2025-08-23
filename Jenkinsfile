pipeline {
    agent any

    stages {
        stage('Clone Repo') {
            steps {
                git branch: 'main', url: 'https://github.com/Anumario/webapp-cicd.git'
            }
        }

        stage('Run Tests') {
    steps {
        sh 'docker run --rm webapp-cicd npm test'
    }
}

       

        stage('Run Container') {
            steps {
                sh 'docker stop webapp || true && docker rm webapp || true'
                sh 'docker run -d --name webapp -p 3000:3000 webapp-cicd'
            }
        }
    }
}
