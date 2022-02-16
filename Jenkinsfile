//stage('GitCheckout & Build') {
//    milestone()
//    node {
//        checkout scm
//        app = docker.build("419466290453.dkr.ecr.sa-east-1.amazonaws.com/rampup-backend:latest")
//    }
//}
//stage('Test'){
//    app.inside{
//        sh 'npm install'
//        sh 'npm test'
//    }
//}
stage('Push & Deploy') {

    milestone()
    node {
        environment{
            db_port = credentials('db_port')
            db_entrypoint = credentials('db_entrypoint')
            db_user = credentials('db_user')
            db_pass = credentials('db_pass')
            db_name = credentials('db_name')
            backend_port = credentials('backend_port')
        }
        //docker.withRegistry("https://419466290453.dkr.ecr.sa-east-1.amazonaws.com", "ecr:sa-east-1:aws_credentials"){
        //    app.push()
        //}
        sh "docker rmi \$(docker image ls --filter reference='*/rampup-backend:*' --format {{.ID}}) || true"
        sh "docker rmi \$(docker image ls --filter 'dangling=true' --format {{.ID}}) || true"
        withCredentials([aws(credentialsId: 'aws_credentials', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
            untaggedImages  = sh(
                script: "aws ecr list-images --region sa-east-1 --repository-name rampup-backend --filter tagStatus=UNTAGGED --query 'imageIds[*]' --output json ",
                returnStdout: true)
            sh "aws ecr batch-delete-image --region sa-east-1 --repository-name rampup-backend --image-ids '${untaggedImages}' || true"
            
            writeFile file: 'inventory.ini', text: "[ec2]\n"
            sh "aws ec2 describe-instances --filter Name=instance.group-name,Values=sg_backend --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text >> inventory.ini"
        }
        withCredentials([file(credentialsId:'ssh_keypair', variable:'ssh_key')]){
            sh "ansible-playbook -i inventory.ini -u ec2-user --private-key $ssh_key deploy_containers.yaml \
            --extra-vars 'db_port=$db_port db_entrypoint=$db_entrypoint db_user=$db_user db_pass=$db_pass db_name=$db_name port=$backend_port'"
        }
    }
}
