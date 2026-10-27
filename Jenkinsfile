```groovy
pipeline {
    agent any

    stages {

        stage('1. Code Checkout') {
            steps {
                echo 'Checking out Text-to-Speech source code'
                checkout scm
            }
        }

        stage('2. Run Selenium Tests with pytest') {
            steps {
                echo 'Installing Python test dependencies'
                bat 'python -m pip install -r requirements.txt'
                bat 'python -m pip install selenium pytest'

                echo 'Starting Text-to-Speech application'
                bat 'start "TTS App" /B python app.py'

                echo 'Waiting for application to start'
                bat 'ping 127.0.0.1 -n 6 > nul'

                echo 'Running Selenium tests'
                bat 'python -m pytest -v tests/test_selenium.py'
            }
        }

        stage('3. Build Docker Image') {
            steps {
                echo 'Building Docker image'
                bat 'docker build -t text-to-speech:%BUILD_NUMBER% .'
            }
        }

        stage('4. Run Application Unit Tests') {
            steps {
                echo 'Running unit tests inside Docker'
                bat 'docker run --rm text-to-speech:%BUILD_NUMBER% python -m pytest -v tests/test_app.py'
            }
        }

        stage('5. Release Docker Image') {
            steps {
                echo 'Creating release tag'
                bat 'docker tag text-to-speech:%BUILD_NUMBER% text-to-speech:release-%BUILD_NUMBER%'
            }
        }

        stage('6. Push Image to Docker Hub') {
            steps {
                echo 'Logging in and pushing Docker image'

                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'padthampranitha',
                        passwordVariable: 'Pranitha@123'
                    )
                ]) {
                    bat '''
                        echo %DH_TOKEN% | docker login -u "%DH_USER%" --password-stdin
                        docker tag text-to-speech:release-%BUILD_NUMBER% pranithapadtham/texttospeech:latest
                        docker tag text-to-speech:release-%BUILD_NUMBER% pranithapadtham/texttospeech:v%BUILD_NUMBER%
                        docker push pranithapadtham/texttospeech:latest
                        docker push pranithapadtham/texttospeech:v%BUILD_NUMBER%
                        docker logout
                    '''
                }
            }
        }

        stage('7. Deploy and Operate') {
            steps {
                echo 'Removing previous container if present'
                bat 'docker rm -f tts-app 2>NUL || exit /b 0'

                echo 'Deploying application container'
                bat 'docker run -d --name tts-app -p 5001:5000 text-to-speech:release-%BUILD_NUMBER%'

                echo 'Checking container status'
                bat 'docker ps'
                bat 'docker inspect tts-app'
            }
        }

        stage('8. Monitor Application') {
            steps {
                echo 'Checking application endpoint'
                bat 'curl.exe --fail --retry 5 --retry-delay 2 --retry-connrefused http://localhost:5001/'

                echo 'Displaying recent application logs'
                bat 'docker logs --tail 50 tts-app'
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
            echo 'Selenium tests passed, image published, and application deployed.'
        }

        failure {
            echo 'Pipeline failed. Please check the Jenkins Console Output.'
        }
    }
}
```
