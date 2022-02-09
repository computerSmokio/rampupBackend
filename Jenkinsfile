stage('GitCheckout & Build') {
    // The first milestone step starts tracking concurrent build order
    milestone()
    node {
        checkout scm
        app = docker.build("419466290453.dkr.ecr.sa-east-1.amazonaws.com/rampup-repo:backend")
        //apply the dockerfile and push the image, nothing else needed
    }
}
stage('Test'){
    app.inside{
        sh 'npm install'
        sh 'npm test'
    }
}
stage('Push & Deploy') {
    milestone()
    node {
        docker.withRegistry("https://419466290453.dkr.ecr.sa-east-1.amazonaws.com", "ecr:sa-east-1:aws_credentials"){
            app.push()
        }
        withCredentials([aws(credentialsId: 'aws_credentials', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
            writeFile file: 'inventory.ini', text: "[ec2]\n"
            sh "aws ec2 describe-instances --filter Name=instance.group-name,Values=sg_frontend --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text >> inventory.ini"
        }
        withCredentials([file(credentialsId:'ssh_keypair', variable:'ssh_key')]){
            sh "ansible-playbook -i inventory.ini -u ec2-user --private-key $ssh_key deploy_containers.yaml"
        }
    }
}
