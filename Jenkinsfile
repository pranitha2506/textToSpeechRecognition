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
        
stage('Deploy to Kubernetes') {
    steps {
        bat 'kubectl apply -f deployment.yaml'
        bat 'kubectl apply -f service.yaml'
        bat 'kubectl rollout status deployment/texttospeech --timeout=120s'
        bat 'kubectl get pods'
        bat 'kubectl get services'
    }
}

stage('Build Selenium Test Image') {
    steps {
        bat 'docker build -f selenium/Dockerfile -t tts-selenium-tests:v1 .'
    }
}

stage('Run Selenium Tests') {
    steps {
        bat '''
            @echo off

            docker network inspect tts-selenium-net >NUL 2>&1
            if errorlevel 1 docker network create tts-selenium-net

            docker rm -f selenium-chrome 2>NUL

            docker run -d --name selenium-chrome ^
                --network tts-selenium-net ^
                -p 4444:4444 ^
                selenium/standalone-chrome:latest

            if errorlevel 1 exit /b 1

            curl.exe --fail --retry 30 --retry-delay 2 ^
                --retry-connrefused http://localhost:4444/status

            if errorlevel 1 exit /b 1

            docker run --rm ^
                --network tts-selenium-net ^
                -e SELENIUM_URL=http://selenium-chrome:4444/wd/hub ^
                -e APP_URL=http://host.docker.internal:30080 ^
                tts-selenium-tests:v1

            if errorlevel 1 exit /b 1

            docker rm -f selenium-chrome
        '''
    }
}

stage('Monitor Kubernetes Application') {
    steps {
        bat 'kubectl get deployment texttospeech'
        bat 'kubectl get pods'
        bat 'kubectl get service texttospeech-service'
        bat 'curl.exe --fail --retry 10 --retry-delay 2 --retry-connrefused http://localhost:30080/'
    }
}

 stage('Docker Login') {
            steps {
                  bat 'docker login -u pranithapadtham -p Pranitha@123'
                }
            }
       
        stage('Push Docker Image to Docker Hub') {
            steps {
                echo 'Pushing Docker Image to Docker Hub'

                bat 'docker tag texttospeech:v1 pranithapadtham/texttospeech:kubeimage1'
                bat 'docker push pranithapadtham/texttospeech:kubeimage1'
            }
        }

        stage('Deploy Application') {
            steps {
                echo 'Deploying application on port 5001'

                bat 'docker rm -f tts-app 2>NUL'
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
            echo 'Application URL: http://localhost:5001'
        }

        failure {
            echo 'Pipeline failed. Check the Jenkins Console Output.'
        }

        always {
            echo 'DevOps pipeline execution finished.'
        }
    }
}
