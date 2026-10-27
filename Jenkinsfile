
pipeline {
    agent any

    options {
        skipDefaultCheckout(true)
    }

    environment {
        IMAGE_NAME = 'text-to-speech'
        CONTAINER_NAME = 'tts-app'
        APP_PORT = '5001'
    }

    stages {

        stage('1. Code Checkout') {
            steps {
                checkout scm
                bat 'git status'
            }
        }

        stage('2. Build Docker Image') {
            steps {
                bat 'docker build -t text-to-speech:%BUILD_NUMBER% .'
            }
        }

        stage('3. Test Application') {
            steps {
                bat 'docker run --rm text-to-speech:%BUILD_NUMBER% python -m unittest discover -s tests -v'
            }
        }

        stage('4. Release') {
            steps {
                bat 'docker tag text-to-speech:%BUILD_NUMBER% text-to-speech:release-%BUILD_NUMBER%'
            }
        }

        stage('5. Deploy') {
            steps {
                bat '''
                docker rm -f tts-app
                '''
                script {
                    // A missing old container is acceptable.
                    // Deployment continues in the next command.
                }
            }
        }

        stage('6. Start Application') {
            steps {
                bat 'docker run -d --name tts-app -p 5001:5000 text-to-speech:release-%BUILD_NUMBER%'
            }
        }

        stage('7. Operate') {
            steps {
                bat 'docker ps'
                bat 'docker inspect tts-app'
            }
        }

        stage('8. Monitor') {
            steps {
                bat 'docker logs tts-app'
                bat 'curl.exe --fail --retry 5 --retry-delay 2 --retry-connrefused http://localhost:5001/'
            }
        }
    }

    post {
        success {
            echo 'Text-to-Speech pipeline completed successfully!'
        }

        failure {
            echo 'Pipeline failed. Check the Console Output for the failed stage.'
        }
    }
}
