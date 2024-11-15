pipeline {
    agent any
    
    environment {
        AWS_ACCESS_KEY_ID = credentials('AKIAYAKVNZFHHV4D7OHQ')
        AWS_SECRET_ACCESS_KEY = credentials('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')
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
