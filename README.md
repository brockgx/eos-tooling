# eos-tooling
The repository to store all tooling scripts for the project EOS Monitor (SEPA/B)

## Consul
Consul will be used as the backend for our Terraform infrastructure. It will store the following for each environment:
* Configuration
  * Here we will store various configuration variables within `.json` files
* State
  * This folder will hold remote state information for each environment and enables locking while the state is being changed by a developer


Folder strucutre as follows:

* Within the Consul directory will be the `main.tf` terraform template file which will initialise a new Consul provider and create key paths for the various configuration and state data discussed above. We also defeine access control policies to restrict access to the Consul backend through the creation of ACL tokens.\

* config
  * This folder will store the `consul-config.hcl` file used to configure our Consul backend
* consul-config-data
  * This folder will store `.json` files that will include various configuration variables such as common tags and resource information needed for our Terraform configurations 

## Terraform
Terraform is used as a tool to automate the deployment of our AWS infrastructure for the EOS remote monitoring application. The purpose of these templates are to create a fully operational AWS VPC (with subnets, routing tables, igw etc.) as well as a number of resources such as a Load Balancer with multiple EC2 instances to route traffic to. Lastly, the templates will detail the creation of an Amazon RDS iinstance complete with subnet group, security group and security keys.

Folder strucutre as follows:
* Modules
  * Here we will store any modules we create for our infrastructure 
* Templates
  * This folder will hold all our templates and other configuration data 
 
The templates are split into two sub directories; one to store configuration templates for the networking infrastructure and the other for the applications configuration templates

#### Networking
* The netowrking templates will deploy the following resources
  * 1 x VPC with 6 x subnets (3 x public and 3 x private) in differrent Availability Zones inside the AWS region
  * 
#### Application



### Initial Setup
Before deploying any infrastrcture on AWS it is necesary to set the AWS credentials by exporting ` AWS_ACCESS_KEY_ID ` and ` AWS_SECRET_ACCESS_KEY ` as environment variables:

```
For windows:
$env:AWS_ACCESS_KEY_ID="VALUE"
$env:AWS_SECRET_ACCESS_KEY="VALUE"

For linux:
export AWS_ACCESS_KEY_ID="VALUE"
export AWS_SECRET_ACCESS_KEY="VALUE"
```



## Ansible

TODO
*
