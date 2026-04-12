provider "aws" {
  region = "eu-central-1"
}

# VPC
resource "aws_vpc" "kaido_main" {
  cidr_block           = "10.0.0.0/16"
  
}

resource "aws_subnet" "kaido_public" {
  vpc_id                  = aws_vpc.kaido_main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false         # Fixed

  tags = {
    Name = "kaido-public"
  }
}

resource "aws_internet_gateway" "kaido_igw" {
  vpc_id = aws_vpc.kaido_main.id
}

resource "aws_route_table" "kaido_routetable" {
  vpc_id = aws_vpc.kaido_main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kaido_igw.id
  }
}

resource "aws_route_table_association" "subnet_association" {
  subnet_id      = aws_subnet.kaido_public.id
  route_table_id = aws_route_table.kaido_routetable.id
}

# Security group for Jenkins
resource "aws_security_group" "jenkins_sg" {
  name   = "jenkins-sg"
  vpc_id = aws_vpc.kaido_main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["62.99.135.46/32"]
  }

  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["62.99.135.46/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM role for EC2 (Jenkins → ECR/S3)
resource "aws_iam_role" "jenkins_role" {
  name = "jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_role_policy_attachment" "s3" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "jenkins-profile"
  role = aws_iam_role.jenkins_role.name
}

# EC2 for Jenkins
resource "aws_instance" "jenkins" {
  ami                    = "ami-0c8678195857f64df"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.kaido_public.id
  key_name               = "daniel-jenkins"
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.jenkins_profile.name

  # Fixed
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required" # IMDSv2 only
  }

  tags = {
    Name = "DevSecOps - Kaido"
  }
}

# ECR repo for banking API image
resource "aws_ecr_repository" "repo" {
  name                 = "devsecops-banking-api"
  image_tag_mutability = "IMMUTABLE"
}

# S3 bucket for artifacts
resource "aws_s3_bucket" "artifacts" {
  bucket = "devsecops-artifacts-123456"
}

output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}

output "ecr_repository_url" {
  value = aws_ecr_repository.repo.repository_url
}
