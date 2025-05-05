@Library("Jenkins-shared-lib") _
pipeline {
    agent {
        label 'java-node'
    }
    tools {
        maven 'Maven-3.8.8'
        jdk 'JDK-17'
    }

    environment {
        app = readMavenPom().getArtifactId()
        app_version = readMavenPom().getVersion()
        app_package = readMavenPom().getPackaging()
        Docker_Hub = "docker.io/kodalimaheshbabu"
        Docker_REPO = "kodalimaheshbabu"
        sonar_url = "http://44.202.158.114:9000"
        sonar_token = credentials('jenkins-sonar')
        ecr_pass = credentials('jenkins-ECR') //token is valid for 12 hours only
        dev_dockerIP = "54.91.212.55"
        stage_dockerIP = "54.91.212.55"
        test_dockerIP = "54.91.212.55"
        environment = "Dev"
    }

    parameters {

        choice(
            name: 'environment',
            choices: ['DEV', 'TEST', 'STAGE'],
            description: 'Select the deployment environment'
        )

        choice(
            name: 'ACTION',
            choices: ['Build', 'Test', 'BuildImage', 'Deploy'],
            description: 'Select the action to perform'
        )

    }

    stages {

        stage('Approval Request') {
            steps {
                script {
                    sendEmail.call(emailID:"gcpgcpmahesh@gmail.com", appName:"${env.app}" )

                }
            }
        }

        stage('Wait for Approval') {
            steps {
                script {
                    input message: 'Waiting for approval from the approver...', ok: 'Approve', submitter: 'approver@example.com'
                }
            }
        }

        stage('Build') {
            when {
                expression {
                    params.ACTION in ['Test', 'BuildImage', 'Deploy', 'Build']
                }
            }
            steps{
                script {
                    buildApp()
                }
            }
        }

        stage('Unit Tests') {
            when {
                expression {
                    params.ACTION in ['Test', 'BuildImage', 'Deploy', 'Build']
                }
            }
            steps{
                script{
                    junitTest()
                }
            }
        }
        stage('Jacoco Code Coverage') {
            when {
                expression {
                    params.ACTION in ['Test', 'BuildImage', 'Deploy', 'Build']
                }
            }
            steps{
                script {
                    jaCoCO()
                }
            }
        }

        stage('Sonar and Quality Gate') {
            when {
                expression {
                    params.ACTION in ['Test', 'BuildImage', 'Deploy', 'Build']
                }
            }
            steps{
                script {
                    sonar()
                }
            }
        }

        stage('Docker Build') {
            when {
                expression {
                    params.ACTION in ['Test', 'BuildImage', 'Deploy', 'Build']
                }
            }
            steps{
                script{
                    dockerBuild()
                }
            }
        }

        stage('Push Image to DockerRepo') {
            when {
                expression {
                    params.ACTION in ['Test', 'BuildImage', 'Deploy', 'Build']
                }
            }
            steps {
                script {
                    pushToDockerRepo()
                }
            }
        }

        stage('DeployToDev') {
            when {
                expression {
                    params.ACTION in ['Test', 'BuildImage', 'Deploy', 'Build']
                }
            }
            steps{
                script{
                    deploy(dockerIP:"3.95.157.212", HostPort:"7761" , ContainerPort:"8761")
                }
            }
        }
    }
}

