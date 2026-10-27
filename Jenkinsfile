pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out Text-to-Speech project'
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'Installing Python dependencies'
                bat 'python -m pip install -r requirements.txt'
                bat 'python -m pip install selenium pytest'
            }
        }

        stage('Run Selenium Tests') {
            steps {
                echo 'Starting Text-to-Speech application'
                bat 'start "TTS App" /B python app.py'

                echo 'Waiting for application to start'
                bat 'ping 127.0.0.1 -n 6 > nul'

                echo 'Running Selenium tests'
                bat 'python -m pytest -v tests/test_selenium.py'
            }
        }

        stage('Run Unit Tests') {
            steps {
                echo 'Running application unit tests'
                bat 'python -m pytest -v tests/test_app.py'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image'
                bat 'docker build -t texttospeech:v1 .'
            }
        }

        stage('Docker Hub Login and Push') {
            steps {
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
                echo 'Deploying Text-to-Speech application'
                bat 'docker rm -f tts-app 2>NUL || exit /b 0'
                bat 'docker run -d --name tts-app -p 5001:5000 texttospeech:v1'
            }
        }

        stage('Monitor Application') {
            steps {
                echo 'Checking application'
                bat 'curl.exe --fail --retry 5 --retry-delay 2 --retry-connrefused http://localhost:5001/'
                bat 'docker logs --tail 50 tts-app'
            }
        }
    }

    post {
        success {
            echo 'Text-to-Speech pipeline completed successfully!'
        }

        failure {
            echo 'Pipeline failed. Check Jenkins Console Output.'
        }

        always {
            echo 'DevOps pipeline execution finished.'
        }
    }
}
