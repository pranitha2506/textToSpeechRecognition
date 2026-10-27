pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out Text-to-Speech project'
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Text-to-Speech Docker image'
                bat 'docker build -t texttospeech:v1 .'
            }
        }

        stage('Run Unit Tests') {
            steps {
                echo 'Running unit tests inside Docker'
                bat 'docker run --rm texttospeech:v1 python -m pytest -v tests/test_app.py'
            }
        }

        stage('Docker Hub Login and Push') {
            steps {
                echo 'Logging in to Docker Hub'

                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DH_USER',
                        passwordVariable: 'DH_TOKEN'
                    )
                ]) {
                    bat '''
                        echo %DH_TOKEN% | docker login -u "%DH_USER%" --password-stdin
                        if errorlevel 1 exit /b 1

                        docker tag texttospeech:v1 padthampranitha/texttospeech:latest
                        if errorlevel 1 exit /b 1

                        docker tag texttospeech:v1 padthampranitha/texttospeech:v1
                        if errorlevel 1 exit /b 1

                        docker push padthampranitha/texttospeech:latest
                        if errorlevel 1 exit /b 1

                        docker push padthampranitha/texttospeech:v1
                        if errorlevel 1 exit /b 1

                        docker logout
                    '''
                }
            }
        }

        stage('Deploy Application') {
            steps {
                echo 'Deploying application on port 5001'

                bat 'docker rm -f tts-app 2>NUL || ver > nul'
                bat 'docker run -d --name tts-app -p 5001:5000 texttospeech:v1'
            }
        }

        stage('Monitor Application') {
            steps {
                echo 'Checking application endpoint'

                bat 'curl.exe --fail --retry 10 --retry-delay 2 --retry-connrefused http://localhost:5001/'

                echo 'Showing application logs'
                bat 'docker logs --tail 50 tts-app'
            }
        }
    }

    post {
        success {
            echo 'Text-to-Speech pipeline completed successfully!'
            echo 'Tests passed, image pushed, and application deployed.'
        }

        failure {
            echo 'Pipeline failed. Check the Jenkins Console Output.'
        }

        always {
            echo 'DevOps pipeline execution finished.'
        }
    }
}
