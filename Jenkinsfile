pipeline{
    agent any
    environment{
        db_entrypoint=credentials('db_entrypoint')
        db_user=credentials('db_user')
        db_pass=credentials('db_pass')
        db_name=credentials('db_name')
        backend_port=credentials('backend_port')
    }
    stages{
        stage('GitCheckout & Build') {
            steps{
                checkout scm
                script{
                    app = docker.build("419466290453.dkr.ecr.sa-east-1.amazonaws.com/rampup-backend:latest")
                }
            }
        }
        stage('Test & Push'){
            steps{
                script{
                    app.inside{
                        sh 'npm install'
                        sh 'npm test'
                    }
                    docker.withRegistry("https://419466290453.dkr.ecr.sa-east-1.amazonaws.com", "ecr:sa-east-1:aws_credentials"){
                        app.push()
                    }
                    withCredentials([aws(credentialsId: 'aws_credentials', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        untaggedImages  = sh(
                            script: "aws ecr list-images --region sa-east-1 --repository-name rampup-backend --filter tagStatus=UNTAGGED --query 'imageIds[*]' --output json ",
                            returnStdout: true)
                        sh "aws ecr batch-delete-image --region sa-east-1 --repository-name rampup-backend --image-ids '${untaggedImages}' || true"
                        writeFile file: 'inventory.ini', text: "[ec2]\n"
                        sh "aws ec2 describe-instances --filter Name=instance.group-name,Values=sg_backend --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text >> inventory.ini"
                    }
                    sh "docker rmi \$(docker image ls --filter reference='*/rampup-backend:*' --format {{.ID}}) || true"
                    sh "docker rmi \$(docker image ls --filter 'dangling=true' --format {{.ID}}) || true"
                }
            }
        }
        stage('Deploy') {
            steps{
                script{
                    withCredentials([file(credentialsId:'ssh_keypair', variable:'ssh_key')]){
                        sh "chef-run master-node /cookbooks/deploy_instances/recipes/deploy_backend.rb -i ${ssh_key} --chef-license"
                    }
                }
            }
        }
    }
}
