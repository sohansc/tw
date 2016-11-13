#!/bin/bash
#Source your account setting file#
if [ "$#" -ne 4 ]; then
 	if [ "$#" -eq 5  ]; then 
		if [[ "$5" == "destroy" ]]; then
                	ACTION="$5"
         	else
                	echo "Usage: sh cloud-automation.sh <application> <environment> <server_count> <server_type>" >&2
			echo "Usage: sh cloud-automation.sh <application> <environment> <server_count> <server_type> destroy" >&2
                	exit 1
         	fi
	else
	 echo "Usage: sh cloud-automation.sh <application> <environment> <server_count> <server_type>" >&2
         echo "Usage: sh cloud-automation.sh <application> <environment> <server_count> <server_type> destroy" >&2
         exit 1
	fi
fi



if [ -n "$1" ]; then
	if ! [ -z "$1" ]; then
		APP="$1"
	else
		echo >&2 'Please provide a valid Application Name'
		exit 1
	fi
fi

if [ -n "$2" ]; then
	if [[ "$2" =~ ^(dev|prod|stag|perf)$ ]]; then
		ENV="$2"
	else
		echo >&2 'Please provide a valid environment'
		exit 1
	fi
fi

if [ -n "$3" ]; then
	if [[ "$3" =~ ^[0-9]+$ ]]; then
		EC2_COUNT="$3"
	else
		echo >&2 'Please provide a valid number to launch valid number of instance'
		exit 1
	fi
fi

if [ -n "$4" ]; then
	if [[ "$4" =~ ^(t2.nano|t2.micro|t2.small|t2.medium|t2.large)$ ]]; then
		EC2_SIZE="$4"
	else
		echo >&2 'Only Allowed to launch T2 type server'
		exit 1
	fi
fi



which terraform >/dev/null
if [ $? -ne 0 ]; then
	echo "Terraform is not present. Expecting terrafom in the \$PATH. Install terraform and proceed."
	sleep 2
	exit 1
fi
echo "Terraform is present..."

if [[ "$5" == "destroy" ]]; then
	echo "Starting terraform destory command:"
       terraform destroy -var-file=./terraform/varible.tfvars -var app=$APP -var env=$ENV -var ec2_size=$EC2_SIZE -var ec2_count=$EC2_COUNT -state=./terraform/terraform.tfstate ./terraform/.
        exit 0
fi

which ansible >/dev/null
if [ $? -ne 0 ]; then
	echo "Ansible is not present. Expecting Ansible in the \$PATH. Install Ansible and proceed."
	sleep 2
	exit 1
fi
echo "Ansible is present..."


#echo "terraform plan -var 'access_key=${ACCESS_KEY}' -var 'secret_key=${SECRET_KEY}'"
terraform apply -var-file=./terraform/varible.tfvars -var app=$APP -var env=$ENV -var ec2_size=$EC2_SIZE -var ec2_count=$EC2_COUNT -state=./terraform/terraform.tfstate ./terraform/.
terraform output -state=./terraform/terraform.tfstate aws_instances_ip | sed -e s/,//g > ./terraform/hosts.txt


export ANSIBLE_HOST_KEY_CHECKING=False

#!/bin/bash 
        COUNTER=1
	Conn_check=`ansible --private-key $ANSIBLE_SSH_PRIVATE_KEY_FILE -u ubuntu -i ./terraform/hosts.txt -m ping all`
	while [[  $COUNTER -lt 20  && ! $Conn_check =~ "SUCCESS" ]]; do
	     echo "$Conn_check"
             echo "AWS instance is still not UP and Running...Failed to do ssh `expr 10 \* $COUNTER` Second elapsed"
             let COUNTER=COUNTER+1 
	     Conn_check=$(echo `ansible --private-key $ANSIBLE_SSH_PRIVATE_KEY_FILE -u ubuntu -i ./terraform/hosts.txt -m ping all`)
	     sleep 10;		
         done

if [[ $Conn_check =~ "SUCCESS" ]] 
then 
	echo "Connection is successfull $Conn_check"
else
	echo "Please check with AWS team. Connection to instance failed : $Conn_check" 
	exit 1
fi


chmod 775 ./terraform/hosts.txt

ansible-playbook --private-key $ANSIBLE_SSH_PRIVATE_KEY_FILE -u ubuntu -i ./terraform/hosts.txt ./ansible/docker.yml



 
