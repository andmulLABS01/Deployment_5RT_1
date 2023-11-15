# Define the provider and region
provider "aws" {
  access_key = ""
  secret_key = ""
  # Replace with your desired AWS region
  region = "us-east-1"  
}

# Create a VPC
resource "aws_vpc" "DP5_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    # Replace with your desired name
    Name = "Dep5-VPC"  
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "DP5_igw" {
  vpc_id = aws_vpc.DP5_vpc.id

  tags = {
    # Replace with your desired name
    Name = "Dep5-VPC-igw"  
  }
}

# Create two subnets in two AZs
resource "aws_subnet" "subnet1" {
  count = 2
  vpc_id = aws_vpc.DP5_vpc.id
  cidr_block = "10.0.${count.index}.0/24"
  availability_zone = "us-east-1${element(["a", "b"], count.index)}"
  map_public_ip_on_launch = true
}

# Create a security group with rules for ports 8080, 8000, and 22
resource "aws_security_group" "DP5_security_group" {
  name = "Dep5_SG"
  description = "Security Group for Deployment 5"
  # Associate the security group with the VPC
  vpc_id = aws_vpc.DP5_vpc.id  

}

# Create an inbound rule for ingress
resource "aws_security_group_rule" "ingress_rules" {
  count = 3
  type = "ingress"
  from_port = element([8080, 8000, 22], count.index)
  to_port = element([8080, 8000, 22], count.index)
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.DP5_security_group.id
}

# Create an outbound rule for egress
resource "aws_security_group_rule" "egress_rule" {
  type = "egress"
  from_port = 0
  to_port = 0  # Allow all outbound traffic
  protocol = "-1"  # All protocols
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.DP5_security_group.id
}

# Create a route table
resource "aws_route_table" "DP5_route_table" {
  vpc_id = aws_vpc.DP5_vpc.id

  tags = {
    # Replace with your desired name
    Name = "Dep5-VPC-rtb"  
  }
  
}

# Associate the route table with the public subnets
resource "aws_route_table_association" "public_subnet_association" {
  count = 2
  subnet_id = aws_subnet.subnet1[count.index].id
  route_table_id = aws_route_table.DP5_route_table.id
}

# Create a route to the Internet Gateway for public subnets
resource "aws_route" "internet_route" {
  route_table_id = aws_route_table.DP5_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.DP5_igw.id
}

# Launch two EC2 instances in the public subnets
resource "aws_instance" "my_ec2_instances" {
  count = 2
  # Replace with your desired AMI ID
  ami = "ami-053b0d53c279acc90"  
  # Choose the instance type you prefer
  instance_type = "t2.micro"     
  vpc_security_group_ids = [aws_security_group.DP5_security_group.id]
  subnet_id = aws_subnet.subnet1[count.index].id
  # Replace with your key pair name
  key_name = "DepKeys"  

  user_data = count.index == 0 ? "${file("s_jenkins.sh")}" : null

  tags = count.index == 0 ? { Name = "Dep_5-Jenkins" } : { Name = "Dep_5-webserver" }
}