
pipeline {
    agent any

    environment {
        IMAGE_NAME = 'text-to-speech'
        CONTAINER_NAME = 'tts-app'
    }

    stages {
        stage('Code Checkout') {
            steps {
                checkout scm
            }
        }

stage('Check Python') {
    steps {
        bat 'where python'
        bat 'where py'
        bat 'echo %PATH%'
    }
}

       
stage('Install Dependencies') {
    steps {
        bat '"C:\\Users\\YourName\\AppData\\Local\\Programs\\Python\\Python312\\python.exe" --version'
        bat '"C:\\Users\\YourName\\AppData\\Local\\Programs\\Python\\Python312\\python.exe" -m pip install -r requirements.txt'
    }
}


        stage('Test') {
            steps {
                bat 'python -m unittest discover -s tests -v'
            }
        }

        stage('Build Docker Image') {
            steps {
                bat 'docker build -t text-to-speech:%BUILD_NUMBER% .'
            }
        }

        stage('Release') {
            steps {
                bat 'docker tag text-to-speech:%BUILD_NUMBER% text-to-speech:release-%BUILD_NUMBER%'
            }
        }

        stage('Deploy') {
            steps {
                bat '''
                docker rm -f tts-app || exit /b 0
                docker run -d --name tts-app -p 5000:5000 text-to-speech:release-%BUILD_NUMBER%
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                bat 'docker ps'
                bat 'curl.exe --retry 5 --retry-delay 2 --retry-connrefused http://localhost:5000/health'
            }
        }
    }
}
