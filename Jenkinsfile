@Library('devops-647')_

pipeline {
    agent any
    tools {
        maven '3.9.9'
    }
    environment {
        COMMIT_SHORT = "180c94b"
        SCANNER_HOME=tool 'sonar-scanner'
    }
    stages {
        stage("Check out"){
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'github-token', url: 'https://github.com/Nsang4625/Boardgame.git']])
                stash name: 'source', includes: '**', excludes: '**/.git,**/.git/**'
            }
        }
        stage('Unit test'){
            steps {
                unitTest(language:"java")
            }
        }
        stage('Code analyst'){
            steps {
                echo "$SCANNER_HOME"
                sonarScan([sonarScanner: "${SCANNER_HOME}", sonarServer: "sonar-server", sonarProjectKey: "Test", sonarHostUrl: "http://sonarqube:9000", sonarToken: "sonar-project-token", qualityGateTimeout: 5])
            }
        }
        stage("Build & push image"){
            agent {
                    label 'buildImage'
            }
            steps {
                buildAndPush(registry:"687511516464.dkr.ecr.us-east-1.amazonaws.com", repository:"project-647-docker", tag:"test", language: "java")
            }
        }
        stage('Trivy scan'){
            steps {
                trivyScan([repository: "project-647-docker", tag: "${COMMIT_SHORT}", registryType: "ecr", awsRegion: "us-east-1" 
                , awsAccountId: "687511516464", commitId: "${COMMIT_SHORT}"])
            }
        }
        stage('Deploy to test env'){
            steps {
                deploy(tag: "${COMMIT_SHORT}", env: "dev", appName: 'mvn', helmRepo: 'github.com/Nsang4625/Project-6.git', githubToken: 'github-token', githubEmail: 'nsang4625@gmail.com')
            }
        }
        stage('ZAP scan'){
            steps {
                zapScan([zapHost: "zap-proxy", zapPort: "8080", targetUrl: "", commitId: "${COMMIT_SHORT}"])
            }
        }
        stage('Notify'){
            steps {
                notify(
                    to: 'nsang4625@gmail.com',
                    from: 'tn4383280@gmail.com',
                    subject: 'Build successfully!',
                    body: """
                        <h2>Build success</h2>
                        <p><b>Trivy report: report.txt</b></p>
                        <p><b>OWASP ZAP report: report.txt</b></p>
                    """
                    )
            }
        }
    }
}