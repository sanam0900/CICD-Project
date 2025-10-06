pipeline {
    agent {
        kubernetes {
            label 'sanam-task'
            defaultContainer 'customimage'
            yamlFile 'pod-template.yaml'
        }
    }
    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'prod'], description: 'Environment to deploy')
    }
    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION    = 'us-east-1'
        DB_USER               = credentials('db-user')
        DB_PASS               = credentials('db-pass')
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Validate Environment') {
            steps {
                script {
                    if (!params.ENVIRONMENT in ['dev', 'staging', 'prod']) {
                        error "Invalid environment: ${params.ENVIRONMENT}. Must be 'dev', 'staging', or 'prod'."
                    }
                    echo "Deploying to environment: ${params.ENVIRONMENT}"
                }
            }
        }
        stage('Configure Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh 'mkdir -p $HOME/.kube && cp $KUBECONFIG $HOME/.kube/config'
                }
            }
        }
        stage('Deploy Database with Terraform') {
            steps {
                dir('terraform') {
                    sh '''
                        terraform init -upgrade
                        terraform apply -var-file="${ENVIRONMENT}.tfvars" -var="environment=${ENVIRONMENT}" -auto-approve
                    '''
                    script {
                        env.DB_HOST = sh(script: 'terraform output -raw db_host', returnStdout: true).trim()
                        env.DB_PORT = sh(script: 'terraform output -raw db_port', returnStdout: true).trim()
                        env.DB_NAME = sh(script: 'terraform output -raw db_name', returnStdout: true).trim()
                    }
                }
            }
        }
        stage('Deploy Application with Helm') {
            steps {
                dir('helm') {
                    sh '''
                        kubectl create namespace "${ENVIRONMENT}" --dry-run=client -o yaml | kubectl apply -f -
                        helm upgrade --install "app-${ENVIRONMENT}" . \
                            --namespace "${ENVIRONMENT}" \
                            --set environment="${ENVIRONMENT}" \
                            --set db.host="${DB_HOST}" \
                            --set db.port="${DB_PORT}" \
                            --set db.name="${DB_NAME}" \
                            --set db.user="${DB_USER}" \
                            --set db.pass="${DB_PASS}"
                    '''
                }
            }
        }
    }
    post {
        always {
            cleanWs()
        }
        success {
            echo "Deployment to ${params.ENVIRONMENT} completed successfully!"
        }
        failure {
            echo "Deployment to ${params.ENVIRONMENT} failed!"
        }
    }
}