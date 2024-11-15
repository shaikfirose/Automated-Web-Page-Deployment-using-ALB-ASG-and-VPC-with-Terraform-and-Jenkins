
pipeline {
    agent any
    
    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION = 'us-east-1'
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
                echo "Terraform action is --> ${action}"
                sh "terraform ${action} --auto-approve"
            }
        }
    }
}
