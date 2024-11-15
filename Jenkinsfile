pipeline {
    agent any
    
    environment {
        AWS_CREDENTIALS_ID = '637ab41b-0b8c-44b8-bb02-24a3b1750d42'  // Replace with your AWS credentials ID in Jenkins
    }

    parameters {
        string(name: 'action', defaultValue: 'plan', description: 'Specify Terraform action (plan or apply)')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage ("terraform init") {
            steps {
                sh 'terraform init -reconfigure' 
            }
        }
        
        stage ("terraform plan") {
            steps {
                sh 'terraform plan -out=tfplan' 
            }
        }

        stage ("terraform Action") {
            steps {
                script {
                    // Using the 'action' parameter here
                    echo "Terraform action is --> ${params.action}"
                    sh "terraform ${params.action} --auto-approve"
                }
            }
        }
    }
}
