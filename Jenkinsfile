stage('GitCheckout & Build') {
    // The first milestone step starts tracking concurrent build order
    milestone()
    node {
        checkout scm
        app = docker.build("419466290453.dkr.ecr.sa-east-1.amazonaws.com/rampup-repo:backend")
        //apply the dockerfile and push the image, nothing else needed
    }
}
stage('Push & Deploy') {
    milestone()
    node {
        docker.withRegistry("https://419466290453.dkr.ecr.sa-east-1.amazonaws.com", "ecr:sa-east-1:aws_credentials"){
            app.push()
        }
        //Para conseguir los hosts: aws ec2 describe-instances --filter "Name=instance.group-name,Values=sg_backend" --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text
        withCredentials([file(credentialsId:'ssh_keypair', variable:'ssh_key')]){
            sh "ansible-playbook -i inventory.yaml -u ec2-user --private-key $ssh_key deploy_containers.yaml"
        }
    }
}
