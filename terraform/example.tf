provider "aws" {
  region     = "us-east-1"
}


# Create a new load balancer
resource "aws_elb" "example" {
  name = "example-elb"
  availability_zones = ["${aws_instance.appserver.*.availability_zone}"]


  listener {
    instance_port = 8080
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }


  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 5
    timeout = 15
    target = "HTTP:8080/"
    interval = 45
  }
cross_zone_load_balancing = true
    idle_timeout = 400
    connection_draining = true
    connection_draining_timeout = 400
  instances = ["${aws_instance.appserver.*.id}"]
security_groups = ["${aws_security_group.elb.id}"]
tags {
        Env = "${var.env}"
}

}

resource "aws_security_group" "elb" {
  name = "elb_sg"
  description = "Used in the terraform"

  # HTTP access from anywhere
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#creating instance
resource "aws_instance" "appserver" {
  ami           = "ami-0d729a60"
  instance_type = "${var.ec2_size}"

connection {
    # The default username for our AMI
    type = "ssh"
    user = "ubuntu"
    private_key = "${file(var.aws_instance_key_pem_file_path)}"
    # The connection will use the local SSH agent for authentication.
  }
key_name = "${var.aws_instace_key_pem_file_name}"
security_groups = ["${aws_security_group.default.name}"]
count = "${var.ec2_count}"
tags {
        Name = "${var.app}-${count.index}"
        Env = "${var.env}"
}
provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y"
    ]

}
}

#creating instance
resource "aws_instance" "webserver" {
  ami           = "ami-0d729a60"
  instance_type = "${var.ec2_size}"

connection {
    # The default username for our AMI
    type = "ssh"
    user = "ubuntu"
    private_key = "${file(var.aws_instance_key_pem_file_path)}"
    # The connection will use the local SSH agent for authentication.
  }
key_name = "${var.aws_instace_key_pem_file_name}"
security_groups = ["${aws_security_group.default.name}"]
count = "${var.ec2_count}"
tags {
        Name = "${var.app}-${count.index}"
        Env = "${var.env}"
}
provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y"
    ]

}
}


resource "aws_security_group" "default" {
    name = "aws_security_group"
    description = "Security configuration defined for aws security group"

    # SSH access from using port 22 only
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # web  access from https port 
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    #web  access from http port
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }



	#access from load balancer port
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

  # outbound internet access
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

output "aws_instances_appserver_ip" {
 value = "${split(",",join(",", aws_instance.appserver.*.public_ip))}" 
}
output "aws_instances_webserver_ip" {
 value = "${split(",",join(",", aws_instance.webserver.*.public_ip))}"
}
output "elb_dns" {
value = "${aws_elb.example.dns_name}"
}
