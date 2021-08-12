# eos-tooling
The repository to store all tooling scripts for the project EOS Monitor (SEPA/B)

## Consul
Consul will be used as the backend for our Terraform infrastructure. It will store the following for each environment:
* Configuration
  * Used to store
Folder strucutre as follows:
* Modules
TODO

## Terraform
Terraform is used as a tool to automate the deployment of our AWS infrastructure for the EOS remote monitoring application

Folder strucutre as follows:
* Modules
  * Here we will store any modules we create for our infrastructure 
* Templates
  * This folder will hold all our templates and other configuration data 
 
The templates are split into two sub directories; one to store configuration templates for the networking infrastructure and the other for the applications configuration templates

### Networking
* The netowrking templa
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
