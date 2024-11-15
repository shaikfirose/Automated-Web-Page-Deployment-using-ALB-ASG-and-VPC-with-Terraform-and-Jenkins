
pipeline {
    agent any
     
    environment {
        AWS_ACCESS_KEY_ID = credentials('637ab41b-0b8c-44b8-bb02-24a3b1750d42') // Use the ID set in Jenkins credentials
        AWS_SECRET_ACCESS_KEY = credentials('637ab41b-0b8c-44b8-bb02-24a3b1750d42') // Use the ID set in Jenkins credentials
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
                sh ('terraform init -reconfigure') 
            }
        }
        stage ("terraform plan") {
            steps {
                sh ('terraform plan -out=tfplan') 
            }
        }
                
        stage ("terraform Action") {
            steps {
                echo "Terraform action is --> ${action}"
                sh ('terraform ${action} --auto-approve') 
           }
        }
    }
}
