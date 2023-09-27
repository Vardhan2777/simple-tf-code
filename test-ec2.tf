#apache-security group
resource "aws_security_group" "ec2-sg" {
  name        = "ec2-sg"
  description = "this is using for securitygroup"
  vpc_id      = aws_vpc.stage-vpc.id

  ingress {
    description     = "this is inbound rule"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "this is inbound rule"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ec2-sg"
  }
}
#ec2userdata
# ec2 instance
resource "aws_instance" "test-ec2" {
  ami                    = var.ami
  instance_type          = var.type
  subnet_id              = aws_subnet.privatesubnet[1].id
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]
  key_name               = aws_key_pair.deployer.id
  iam_instance_profile   = aws_iam_instance_profile.ssm_agent_instance_profile.name
  #user_data              = data.template_file.apacheuser.rendered
  user_data = file("scripts/ec2.sh")
  tags = {
    Name = "test-ec2"
  }
}