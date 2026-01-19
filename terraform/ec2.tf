# creating security group 
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.main.id


  # inbound rules (allow SSH access from anywhere)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allows web traffic from public internet 
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound Rules (can talk to anything on the internet)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"

  }
}

resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "sre-public-subnet-1"
  }
}


# now we create our instance 
resource "aws_instance" "web" {
  ami                    = "ami-0c02fb55956c7d316" # Amazon Linux 2 (us-east-1)
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public1.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = "derek-keypair"

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    docker run -d -p 80:80 nginx
  EOF

  tags = {
    Name = "sre-web-server"
  }
}

