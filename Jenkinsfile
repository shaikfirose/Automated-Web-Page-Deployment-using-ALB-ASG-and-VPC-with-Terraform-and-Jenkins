pipeline {
    agent any
    
    environment {
        AWS_CREDENTIALS_ID = '637ab41b-0b8c-44b8-bb02-24a3b1750d42'  // Replace with your AWS credentials ID in Jenkins
    }

    parameters {
        choice(name: 'action', choices: ['apply', 'destroy'], description: 'Specify Terraform action (apply or destroy)')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage("terraform init") {
            steps {
                sh 'terraform init -reconfigure' 
            }
        }
        
        stage("terraform plan") {
            steps {
                sh 'terraform plan -out=tfplan' 
            }
        }


        stage("terraform Action") {
            steps {
                script {
                    echo "Terraform action is --> ${params.action}"

                    // Conditionally handle 'apply' and 'destroy'
                    if (params.action == 'apply') {
                        echo "Running terraform apply"
                        sh "terraform apply --auto-approve"  // Run terraform apply with --auto-approve
                    } else if (params.action == 'destroy') {
                        echo "Running terraform destroy"
                        sh "terraform destroy --auto-approve"  // Run terraform destroy with --auto-approve
                    } else {
                        error "Invalid action: ${params.action}. Only 'apply' or 'destroy' are supported."
                    }
                }
            }
        }
    }
}
