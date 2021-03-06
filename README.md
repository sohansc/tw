#Application and Web Server Provisioning using AWS TERRAFORM ANSIBLE DOCKER

A Terraform / Ansible / Docker config to deploy infrastructure on AWS : This script file and playbook create a number of AWS instance using Terraform  and ansible-playbook, Load balancing is done automatically(if require) between multiple app instances of application through AWS load balancer

#Prerequisite:
1. Installation of Terraform :
https://www.terraform.io/downloads.html
2. Installation of Ansible :
http://docs.ansible.com/ansible/intro_installation.html#latest-releases-via-pip 
if require, installation of python : https://www.python.org/downloads/
3. Should have following environment variables set:

```
export AWS_ACCESS_KEY_ID=“AWS User access Key id”
export AWS_SECRET_ACCESS_KEY=“AWS user secret  key“
export ANSIBLE_SSH_PRIVATE_KEY_FILE=“AWS instance ssh login key”
export ANSIBLE_HOST_KEY_CHECKING=False
```

#Usage

Run the following commands:

To create instance :
```
./cloud-automation.sh <APP_NAME> <ENVIRONMENT> <COUNT> <SIZE>
```
To destroy instance :
```
./cloud-automation.sh <APP_NAME> <ENVIRONMENT> <COUNT> <SIZE> destroy
```

```
<APP_NAME>      Name of the app you wish to set
<ENVIRONMENT>   The environment name (dev|prod|stag|perf)
<COUNT>         Number of Wordpress instances required (integer 1 : one webserver, one appserver, 2: two webserver, app server)
<SIZE>          AWS instance type for example "t2.*”

```

To be done: 
1. Incorporating version war and jar deployment in provioned server.
2. Distinguish appserver and webserver count.
