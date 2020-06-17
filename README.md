# terraform
terraform-Examples

# Terraform Version - Terraform v0.12.26
# AWS provider plugin - terraform-provider-aws_v2.66.0_x4

# How to Run

- Clone Repo
- Change Access And Secret in Cred File
- In Cloned directory run 
# terraform init 
- which will download provider plugin
- After this run 
# terraform plan 
- which will show the changes it'll make on AWS
- After that you can run
# terraform apply
- which will deploy the infra once you'll enter 'yes' whem it prompts for 

- lab.tf file has all the code and set Path for cred Accordingly

# Steps Performed -

- Access and secret keys declared in cred file
- Create VPC with name Bastion-VPC with this cidr 10.0.0.0/16
- tenancy default and enabled dns support and hostname on VPC
- Region US-EAST-1


- Creating Internet Gateway with name IGW

- Creating public Subnet in US-EAST-1A
- CIDR 10.0.2.0/24
- Setting Public IP true
- Naming it Pub-1


- Creating public Subnet in US-EAST-1B
- CIDR 10.0.4.0/24
- Setting Public IP true
- Naming it Pub-2


- Creating private Subnet in US-EAST-1A
- CIDR 10.0.6.0/24
- Setting Public IP false
- Naming it Private-1


- Creating private Subnet in US-EAST-1B
- CIDR 10.0.8.0/24
- Setting Public IP false
- Naming it Private-2


- Creating private Subnet for DB in US-EAST-1A
- CIDR 10.0.12.0/24
- Setting Public IP false
- Naming it Private-db-1


- Creating private Subnet for DB in US-EAST-1B
- CIDR 10.0.14.0/24
- Setting Public IP false
- Naming it Private-db-2


- Creating Public Route table and naming it public-route
- Associating IGW with this route
- Associating both public Subnet with this 


- Two Zones so creating two Nat GateWay
- Creating EIP for NGW in us-east-1a 
- Naming EIP as NGW-A
- Creating EIP for NGW in us-east-1b 
- Naming EIP as NGW-B


- Associating this NGW-A with public subnet of us-east-1a
- Associating this NGW-B with public subnet of us-east-1b


- Creating Route table for private subnet in us-east-1a and naming it private-route-A
- Associating NGW-A with this table
- Associating both private subnet (Private-1 & Private-db-1) with this table


- Creating Route table for private subnet in us-east-1b and naming it private-route-B
- Associating NGW-B with this table
- Associating both private subnet (Private-2 & Private-db-2) with this table

- Generating key For Bastion Host
- Using Public key in TF file and private file is with name bastion-key.pem in current directory


- Generating key For private App Host
- Using Public key in TF file and private file is with name app-key.pem in current directory


- Creating Security Group for Bastion/Jumpbox Host 
- Naming it Bastion-Security-Group
- Setting port for SSH, HTTP and HTTPS


- Creating Security Group for Private App instances
- Naming it Private-App-Security-Group
- Setting Port 22 only for Bastion-Security-Group


- Allocating EIP and Naming it Bastion/JumpBox
- Creating Instance with Ubuntu 20 AMI  
- Instance t3.small
- Disk is 15GB
- Public Subnet in us-east-1a
- With Key of bastion-key.pem which is created earlier
- With Security Group Of Bastion which is created earlier
- Naming Instance Bastion/JumpBox
- Associating EIP with this Instance


- Creating Private instance with Ubuntu 20 AMI
- Instance t3.small
- Disk 15GB
- Private Subnet us-east-1a
- Security Group Private-App-Security-Group
- key app-key.pem
- Name Private-App1-AZ-A


- Creating Private instance with Ubuntu 20 AMI
- Instance t3.small
- Disk 15GB
- Private Subnet us-east-1a
- Security Group Private-App-Security-Group
- key app-key.pem
- Name Private-App2-AZ-A


- Creating Private instance with Ubuntu 20 AMI
- Instance t3.small
- Disk 15GB
- Private Subnet us-east-1b
- Security Group Private-App-Security-Group
- key app-key.pem
- Name Private-App1-AZ-B


- Creating Private instance with Ubuntu 20 AMI
- Instance t3.small
- Disk 15GB
- Private Subnet us-east-1b
- Security Group Private-App-Security-Group
- key app-key.pem
- Name Private-App2-AZ-B

- Creating RDS Subnet Group
- Associating Both Private DB Subnets
- Naming it Private-DB-Subnet-Group


- Creating RDS Security group
- Allowing 3306 only for Private-App-Security-Group
- Naming it Private-DB-Security-Group


- Creating RDS Instance 
- in us-east-1a
- Port 3306
- Naming it mysqldb
- associating Private-DB-Subnet-Group
- Engine Mysql
- STorage 20GB
- Engine Version 8.0.17
- Public Access Disable
- Multi-Az Disable
- Instance type db.t2.small
- backup retention 7
- User - admin
- Pass - R6hE6HmIkh

