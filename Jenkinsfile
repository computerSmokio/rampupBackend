pipeline{
    agent any
    environment{
        db_entrypoint=credentials('db_entrypoint')
        db_user=credentials('db_user')
        db_pass=credentials('db_pass')
        db_name=credentials('db_name')
        bk_port=credentials('bk_port')
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
        stage('Push'){
            steps{
                script{
                    docker.withRegistry("https://419466290453.dkr.ecr.sa-east-1.amazonaws.com", "ecr:sa-east-1:aws_credentials"){
                        app.push()
                    }
                    withCredentials([aws(credentialsId: 'aws_credentials', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        untaggedImages  = sh(
                            script: "aws ecr list-images --region sa-east-1 --repository-name rampup-backend --filter tagStatus=UNTAGGED --query 'imageIds[*]' --output json ",
                            returnStdout: true)
                        sh "aws ecr batch-delete-image --region sa-east-1 --repository-name rampup-backend --image-ids '${untaggedImages}' || true"
                        master_node_ip  = sh(
                            script: "aws ec2 describe-instances --region sa-east-1  --filter Name=instance.group-name,Values=master-node-sg --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text",
                            returnStdout: true)
                        master_node_ip=master_node_ip.substring(0,master_node_ip.indexOf('\n'))
                    }
                    sh "docker rmi \$(docker image ls --filter reference='*/rampup-backend:*' --format {{.ID}}) || true"
                    sh "docker rmi \$(docker image ls --filter 'dangling=true' --format {{.ID}}) || true"
                }
            }
        }
        stage('Deploy') {
            steps {
                withCredentials([file(credentialsId:'ssh_keypair', variable:'ssh_key')]){
                    sh "ssh -o StrictHostKeyChecking=no -i ${ssh_key} ec2-user@${master_node_ip} kubectl create secret generic db-secrets --from-literal=db.entrypoint=${db_entrypoint} --from-literal=db.user=${db_user} --from-literal=db.pass=${db_pass} --from-literal=db.name=${db_name} -n rampup-backend-ns"
                    sh "ssh -o StrictHostKeyChecking=no -i ${ssh_key} ec2-user@${master_node_ip} kubectl create secret generic backend-secrets --from-literal=bk.url=${bk_url} --from-literal=bk.port=${bk_port} -n rampup-backend-ns"
                    sh "ssh -o StrictHostKeyChecking=no -i ${ssh_key} ec2-user@${master_node_ip} sudo chef-client -o deploy_instances::deploy_backend"
                }
            }
        }
    }
}
