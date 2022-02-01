stage('Build') {
    // The first milestone step starts tracking concurrent build order
    milestone()
    node {
        echo "Building"
        checkout scm
        app = docker.build("419466290453.dkr.ecr.sa-east-1.amazonaws.com/rampup-repo:backend")
        //apply the dockerfile and push the image, nothing else needed
    }
}
stage('Deploy') {
    input "Deploy?"
    milestone()
    node {
        echo "Deploying"
        docker.withRegistry("https://419466290453.dkr.ecr.sa-east-1.amazonaws.com", "ecr:sa-east-1:aws_credentials"){
            app.push()
        }
    }
}
