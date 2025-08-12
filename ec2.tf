resource "aws_instance" "jenkins" {
  ami                    = var.ec2_ami
  instance_type          = var.eks_instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.jenkins_profile.name

  user_data = <<-EOF
    #!/bin/bash
    
    sudo apt update && sudo apt upgrade -y

    # install docker
    sudo apt install docker.io

    # install awscli v2
    sudo apt install -y unzip curl
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install

    # install kubectl
    curl -LO "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz"
    tar -xzf eksctl_Linux_amd64.tar.gz
    sudo mv eksctl /usr/local/bin

    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

    curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/aws-iam-authenticator
    chmod +x ./aws-iam-authenticator
    sudo mv ./aws-iam-authenticator /usr/local/bin

    # Update and install prerequisites
    apt update -y
    apt install -y fontconfig wget apt-transport-https software-properties-common

    # Install Java 21
    apt install -y openjdk-21-jre

    # Add Jenkins GPG key and repo
    wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | tee \
      /usr/share/keyrings/jenkins-keyring.asc > /dev/null

    echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
      https://pkg.jenkins.io/debian-stable binary/ | tee \
      /etc/apt/sources.list.d/jenkins.list > /dev/null

    # Install Jenkins
    apt update -y
    apt install -y jenkins

    # Enable and start Jenkins
    systemctl enable jenkins
    systemctl start jenkins
  EOF

  tags = {
    Name = "jenkins-server"
  }
}
