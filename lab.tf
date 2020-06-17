provider "aws" {
  region     = "us-east-1"
  shared_credentials_file = "/home/muhammad-irfan/work/terraform/terraform-aws/vpc/cred"
  profile                 = "customprofile"
}


# Creating VPC WIth Name Bastion-VPC
resource "aws_vpc" "new" {

  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "Bastion-VPC"
  }
}


#Creating Internet GateWay
resource "aws_internet_gateway" "IGW" {

  vpc_id = aws_vpc.new.id
  tags = {
    Name = "IGW"
  }
}


#Creating Public Subnet with AZ - US-East-1a
resource "aws_subnet" "public-sub" {

  vpc_id = aws_vpc.new.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags = {
     Name = "Pub-1"
  }
}


#Creating Public Subnet with AZ - US-East-1b
resource "aws_subnet" "public-sub1" {

  vpc_id = aws_vpc.new.id
  cidr_block = "10.0.4.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"
  tags = {
     Name = "Pub-2"
  }
}


#Creating Private Subnet with AZ - US-East-1a
resource "aws_subnet" "private-sub" {

  vpc_id = aws_vpc.new.id
  cidr_block = "10.0.6.0/24"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1a"
  tags = {
     Name = "Private-1"
  }
}


#Creating private Subnet with AZ - US-East-1b
resource "aws_subnet" "private-sub1" {

  vpc_id = aws_vpc.new.id
  cidr_block = "10.0.8.0/24"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1b"
  tags = {
     Name = "Private-2"
  }
}


#Creating Private Subnet db with AZ - US-East-1a
resource "aws_subnet" "private-sub-db" {

  vpc_id = aws_vpc.new.id
  cidr_block = "10.0.12.0/24"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1a"
  tags = {
     Name = "Private-db-1"
  }
}


#Creating private Subnet db with AZ - US-East-1b
resource "aws_subnet" "private-sub1-db" {

  vpc_id = aws_vpc.new.id
  cidr_block = "10.0.14.0/24"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1b"
  tags = {
     Name = "Private-db-2"
  }
}



#Creating Route Table For with IGW
resource "aws_route_table" "Public-Route" {

  vpc_id = aws_vpc.new.id

  route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
     Name = "public-route"
  }

}

#Associating Public Subnet
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public-sub.id
  route_table_id = aws_route_table.Public-Route.id
}

#Associating Public Subnet
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public-sub1.id
  route_table_id = aws_route_table.Public-Route.id
}


#Creating EIP For NGW US-East-1a
resource "aws_eip" "Eip" {
  vpc              = true
  tags = {
    Name = "NGW-A"
  }
}


#Creating EIP For NGW US-East-1b
resource "aws_eip" "Eip2" {
  vpc              = true
  tags = {
    Name = "NGW-B"
  }
}

#NGW For US-East-1a
resource "aws_nat_gateway" "NGW-A" {
    allocation_id = aws_eip.Eip.id
    subnet_id = aws_subnet.public-sub.id
    tags = {
       Name = "NAT-GW-US-EAST-1A"
    }
}

#NGW For US-East-1b
resource "aws_nat_gateway" "NGW-B" {
    allocation_id = aws_eip.Eip2.id
    subnet_id = aws_subnet.public-sub1.id
    tags = {
       Name = "NAT-GW-US-EAST-1B"
    }
}


#Creating Route Table For Private Subnet us-east-1a
resource "aws_route_table" "Private-Route-A" {

  vpc_id = aws_vpc.new.id

  route {
  cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.NGW-A.id
  }

  tags = {
     Name = "private-route-A"
  }

}

#Associating Private Subnet us-east-1a
resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.private-sub.id
  route_table_id = aws_route_table.Private-Route-A.id
}


#Associating Private Subnet DB us-east-1a
resource "aws_route_table_association" "db" {
  subnet_id      = aws_subnet.private-sub-db.id
  route_table_id = aws_route_table.Private-Route-A.id
}



#Creating Route Table For Private Subnet us-east-1b
resource "aws_route_table" "Private-Route-B" {

  vpc_id = aws_vpc.new.id

  route {
  cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.NGW-B.id
  }

  tags = {
     Name = "private-route-B"
  }

}

#Associating Private Subnet us-east-1b
resource "aws_route_table_association" "d" {
  subnet_id      = aws_subnet.private-sub1.id
  route_table_id = aws_route_table.Private-Route-B.id
}

#Associating Private Subnet DB us-east-1b
resource "aws_route_table_association" "db1" {
  subnet_id      = aws_subnet.private-sub1-db.id
  route_table_id = aws_route_table.Private-Route-B.id
}

#Generating Key For Bastion/Jumpbox Host
resource "aws_key_pair" "bastion" {

  key_name = "bastion-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCH7n16tMD3dRGScv2GoV4NdnZGRZLNke3TJ+LDUKg6fzK+LuR7hrswFcg27lrZ8+U6kaILawwhTIaUTicXBZVm+dfFXvlV8WJG3X8uOeFlLYHMXjkEHMBcJm14wBJBP9YEsrlUdp/OjzzxoG5Pk5vFoCYUf9ZbxcXBBa9j3zdxOS75SdTtMgxPZY84V+8215ThWTZWon0KcMp3XpJYHUCPjcP9VDUaAR156XFUNw9zJPnfGSE1bX1R9Jx+uNzsK2yZYVvivqtIzmkxqv1Qy9m9IgEQ4Zmbx/19k17mwxcGWRmEU1IwairY4ikVrZEprTtcwBFp1U/EKMLd5AE3jROD"

}

#Generating Key For Private-App Instance
resource "aws_key_pair" "private-app" {

  key_name = "app-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCUL8FSoMcWG7P/S3s7F5TW3qAX1rkwz+4Jch6qRw+J+nUYpXytpuvvUxR3gCO+Ccd84OgUKruBNxl0pZ7xaJMk772rzI/8+uDDCQAZU7X6EJ2pJ/CH4oE3zLWbAac2t6g0GmqXZ472tZ6h1nyAxK39TRIq6UVFpY4qDlylivPAS6DzASRmxyL9JPzstq9IJ9vYzSYSaf4lm93sZLcZJ4XTuE9YocMJLXYf17MBms+WcHhKSa3U4dunZ4G1sYxOw8G3HiTDpgvRfMhkiaLjrWQxOiFi/sL5DhFaVq9w0xdaIN3LUJUI3jWDJzf43UJzEB9DzrQEg+fLyFmehu1/Ewk1"

}



#Creating Bastion Security Group
resource "aws_security_group" "bastion-SG" {
  name        = "Bastion-Security-Group"
  description = "Bastion-Security-Group"
  vpc_id      = aws_vpc.new.id

  ingress {
    description = "SSH Traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP Traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "HTTPS Traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

#Outbound Trrafic Specify to allow all, Terraform will not add this by default
  egress {
  description = "Allow All"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
 }

 tags = {
    Name = "Bastion-Security-Group"
 }

}

#Creating Private App security Group
resource "aws_security_group" "private-SG" {
  name        = "Private-App-Security-Group"
  description = "Private-App-Security-Group"
  vpc_id      = aws_vpc.new.id

  ingress {
    description = "SSH Traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = ["${aws_security_group.bastion-SG.id}"]
  }

  #Outbound Trrafic Specify to allow all, Terraform will not add this by default
    egress {
    description = "Allow All"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
   }

   tags = {
      Name = "Private-App-Security-Group"
   }

  }


  #Creating EIP For Bastion/JumpBox
  resource "aws_eip" "bastion-eip" {
    vpc              = true
    tags = {
      Name = "Bastion/JumpBox"
    }
  }

  #Creating Bastion/JumpBox EC2 Instance

  resource "aws_instance" "bastion-instance" {

    #ubuntu 20 AMI
    ami = "ami-068663a3c619dd892"
    instance_type = "t3.small"
    vpc_security_group_ids = ["${aws_security_group.bastion-SG.id}"]
    key_name = aws_key_pair.bastion.id
    subnet_id = aws_subnet.public-sub.id
    root_block_device {

      volume_type = "gp2"
      volume_size = 15
      delete_on_termination = true

    }

    tags = {
       Name = "Bastion/JumpBox"
    }

  }


  #Associating EIP to Bastion/JumpBox
  resource "aws_eip_association" "eip_assoc" {
    instance_id   = aws_instance.bastion-instance.id
    allocation_id = aws_eip.bastion-eip.id
  }


#Creating Private App Instance in Us-East-1a
  resource "aws_instance" "private1-a" {

    #ubuntu 20 AMI
    ami = "ami-068663a3c619dd892"
    instance_type = "t3.small"
    vpc_security_group_ids = ["${aws_security_group.private-SG.id}"]
    key_name = aws_key_pair.private-app.id
    subnet_id = aws_subnet.private-sub.id
    root_block_device {

      volume_type = "gp2"
      volume_size = 15
      delete_on_termination = true

    }

    tags = {
       Name = "Private-App1-AZ-A"
    }

  }


  #Creating Private App Instance in Us-East-1a
    resource "aws_instance" "private2-a" {

      #ubuntu 20 AMI
      ami = "ami-068663a3c619dd892"
      instance_type = "t3.small"
      vpc_security_group_ids = ["${aws_security_group.private-SG.id}"]
      key_name = aws_key_pair.private-app.id
      subnet_id = aws_subnet.private-sub.id
      root_block_device {

        volume_type = "gp2"
        volume_size = 15
        delete_on_termination = true

      }

      tags = {
         Name = "Private-App2-AZ-A"
      }

    }


    #Creating Private App Instance in Us-East-1b
      resource "aws_instance" "private1-b" {

        #ubuntu 20 AMI
        ami = "ami-068663a3c619dd892"
        instance_type = "t3.small"
        vpc_security_group_ids = ["${aws_security_group.private-SG.id}"]
        key_name = aws_key_pair.private-app.id
        subnet_id = aws_subnet.private-sub1.id
        root_block_device {

          volume_type = "gp2"
          volume_size = 15
          delete_on_termination = true

        }

        tags = {
           Name = "Private-App1-AZ-B"
        }

      }


      #Creating Private App Instance in Us-East-1b
        resource "aws_instance" "private2-b" {

          #ubuntu 20 AMI
          ami = "ami-068663a3c619dd892"
          instance_type = "t3.small"
          vpc_security_group_ids = ["${aws_security_group.private-SG.id}"]
          key_name = aws_key_pair.private-app.id
          subnet_id = aws_subnet.private-sub1.id
          root_block_device {

            volume_type = "gp2"
            volume_size = 15
            delete_on_termination = true

          }

          tags = {
             Name = "Private-App2-AZ-B"
          }

        }

      # RDS Subnet Group
    resource "aws_db_subnet_group" "RDS-Subnet" {

              name = "private-db-subnet-group"
              description = "Private-DB-Subnet-Group"
              subnet_ids = ["${aws_subnet.private-sub-db.id}", "${aws_subnet.private-sub1-db.id}"]
              tags = {
                  Name = "Private-DB-Subnet-Group"
                }
        }

      # RDS Security Group Create
      resource "aws_security_group" "private-db-SG" {
        name        = "Private-DB-Security-Group"
        description = "Private-DB-Security-Group"
        vpc_id      = aws_vpc.new.id

        ingress {
          description = "MYSQL Traffic"
          from_port   = 3306
          to_port     = 3306
          protocol    = "tcp"
          security_groups = ["${aws_security_group.private-SG.id}"]
        }

        #Outbound Trrafic Specify to allow all, Terraform will not add this by default
          egress {
          description = "Allow All"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
         }

         tags = {
            Name = "Private-DB-Security-Group"
         }

        }

#Creating RDS Instance in Us-east-1a
      resource "aws_db_instance" "RDS-Instance" {
        allocated_storage    = 20
        storage_type         = "gp2"
        engine               = "mysql"
        engine_version       = "8.0.17"
        instance_class       = "db.t2.small"
        name                 = "mydb"
        username             = "admin"
        password             = "R6hE6HmIkh"
        db_subnet_group_name = aws_db_subnet_group.RDS-Subnet.id
        availability_zone    = "us-east-1a"
        vpc_security_group_ids = ["${aws_security_group.private-db-SG.id}"]
        port                 = 3306
        publicly_accessible  = false
        multi_az             = false
        backup_retention_period = 7
        identifier           = "mysqldb"
        deletion_protection = true
        tags = {
           Name = "Database-RDS"
        }
      }
