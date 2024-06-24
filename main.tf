module "jenkins" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                   = "jenkins-tf"
  vpc_security_group_ids = ["sg-0f903b95a2eb61568"]   #replace your SG
  subnet_id              = "subnet-02eca919c772ca9cb" #replace your Subnet

  instance_type = "t3.small"
  ami           = data.aws_ami.ami_info.id
  user_data     = file("jenkins.sh")
  tags = {
    Name = "jenkins-tf"
  }

}
module "jenkins_agent" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                   = "jenkins-agent"
  vpc_security_group_ids = ["sg-0f903b95a2eb61568"]   #replace your SG
  subnet_id              = "subnet-02eca919c772ca9cb" #replace your Subnet

  instance_type = "t3.small"
  ami           = data.aws_ami.ami_info.id
  user_data     = file("jenkins-agent.sh")
  tags = {
    Name = "jenkins-agent"
  }

}


resource "aws_key_pair" "jenkin1" {
  key_name   = "jenkin1"
  # we can paste the public key directly like this
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDSmCYzZL3FL9jSqJjNGSpEinsTvwUMe97MeudD+oMnZzZbdYgf+4Cz0czliNw/94jKSdrdjWYV7ijw0/+Q728MVk4cgJWRmhFzIpPCm6luKNjW3AMDi4gM1hfbibQ1Pi+peCdLiYZar/Q9ZwRwFLydOi205JaZZ6JgTUAqUazeKYOPTiK6006cpKyBRvZYyG2u1OXqiAag+yIWJb1rvGJbid0wWJ+HLtvTpTGRPETEvrdGET+cMKvb3SMkDkdrPnjUYN4i/TNbBh1WEnksZsbmnevOG8icY/pU4BdAgkorzP/Zbyud9N7Va7Gsp3N7yrEt7MR8keTy8lYTAxn+h7cKgUAd9aLR3liowcneZIVpGzbjJKGPjpE0Ezi+p9VZdtnxjwF0b583cyzp4PDduXJVQ0YDneSoiUZ2mBxWt1r7vD7Z8UIl8uYNhKj4x2khFcXhF2gzu0T/y7KbZpDbjK79h3aiQkdDcg0MuADJgbMKcwR8gyiy0G64w02whfvqRQE= user@SK"
  # ~ means windows home directory
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name

  records = [
    {
      name    = "jenkins"
      type    = "A"
      ttl     = 1
      records = [
        module.jenkins.public_ip
      ]
      allow_overwrite = true
    },
    {
      name    = "jenkins-agent"
      type    = "A"
      ttl     = 1
      records = [
        module.jenkins_agent.private_ip
      ]
      allow_overwrite = true
    },
    {
      name    = "nexus"
      type    = "A"
      ttl     = 1
      records = [
        module.nexus.private_ip
      ]
      allow_overwrite = true
    }

  ]
}



module "nexus" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                   = "nexus"
  vpc_security_group_ids = ["sg-0f903b95a2eb61568"]   #replace your SG
  subnet_id              = "subnet-02eca919c772ca9cb" #replace your Subnet

  instance_type = "t3.medium"
  ami           = data.aws_ami.nexus_ami_info.id
  tags = {
    Name = "Nexus"
  }

}