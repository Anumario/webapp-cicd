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

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([
                    file(credentialsId: 'kubeconfig-webapp', variable: 'KUBECONFIG_FILE'),
                    usernamePassword(credentialsId: 'ghcr-creds', usernameVariable: 'GHCR_USER', passwordVariable: 'GHCR_PAT')
                ]) {
                    sh """
                        export KUBECONFIG="$KUBECONFIG_FILE"

                        # 1) Assurer que namespace existe
                        kubectl get ns webapp || kubectl create namespace webapp

                        # 2)(Re)créer le secret GHCR (idempotent)
                        kubectl -n webapp create secret docker-registry ghcr-secret \
                          --docker-server=ghcr.io \
                          --docker-username="$GHCR_USER" \
                          --docker-password="$GHCR_PAT" \
                          --docker-email="anumariocorreia@gmail.com" \
                          --dry-run=client -o yaml | kubectl apply -f -

                        # 3) Appliquer les manifestes (ajuster les paths si nécessaire)
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml

                        # 4) Mettre à jour l'image pour la version de build
                        kubectl -n webapp set image deploy/webapp webapp=${IMAGE}:${VERSION} --record

                        # 5) Attendez le déploiement
                        kubectl -n webapp rollout status deploy/webapp --timeout=180s

                        # 6) Afficher les pods en exécution
                        kubectl -n webapp get pods -o wide
                    """
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

