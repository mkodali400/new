terraform {
  required_version = "1.9.8"
  required_providers {
    aws = {
      version = ">= 5.0.0"
      source =  "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.aws_region.North-America
  profile = "project"
}

resource "aws_key_pair" "key_pair" {
  key_name   = "project-key-pair"
  public_key = file("~/.ssh/id_rsa.pub")
  tags = {
    "Name" = "project-key"
  }
}

resource "aws_security_group" "SG" {
  name = "project-SG"
  description = "To allow inbound traffic on port defined by user"
  dynamic "ingress" {
    for_each = var.ports_in
    content {
      to_port = ingress.value
      from_port = ingress.value
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  dynamic "egress" {
    for_each = var.ports_out
    content {
      to_port = egress.value
      from_port = egress.value
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

resource "aws_ebs_volume" "ebs-volume" {
  for_each = var.instance_names
  availability_zone = var.aws_az.North-America
  type = "gp3"
  size = "20"
  tags = {
    "Name" = each.key
  }
}

resource "aws_volume_attachment" "ebs-to-ec2" {
  for_each = var.instance_names
  device_name = "/dev/sdh"
  instance_id = aws_instance.ec2[each.key].id
  volume_id   = aws_ebs_volume.ebs-volume[each.key].id
}

resource "aws_instance" "ec2" {
  for_each = var.instance_names
  ami = var.ami_ids.Amazon_Linux
  availability_zone = var.aws_az.North-America
  instance_type = each.key == "sonar" || each.key == "jenkins-slave" || each.key == "docker"  ?  "t2.small" : var.instance_type
  key_name = aws_key_pair.key_pair.key_name
  security_groups = [aws_security_group.SG.name]
  connection {
    type = "ssh"
    host = self.public_ip
    user = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
  }

  provisioner "file" {
    source = "/Users/mahesh/.ssh/id_rsa"
    destination = "/home/ec2-user/.ssh/id_rsa"
  }
   provisioner "remote-exec" {
     inline = ["chmod 0700 /home/ec2-user/.ssh/id_rsa"]
   }

  provisioner "file" {
    source =  each.key == "ansible-controller" ? "/Users/mahesh/Desktop/projects/eureka/eureka/terraform/playbook-jenkins-install-master.yaml" : "empty.txt"
    destination = each.key == "ansible-controller" ? "/home/ec2-user/playbook-jenkins-install-master.yaml" : "empty.txt"
  }

    provisioner "file" {
    source =  each.key == "ansible-controller" ? "/Users/mahesh/Desktop/projects/eureka/eureka/terraform/playbook-jenkins-slave.yaml" : "empty.txt"
    destination = each.key == "ansible-controller" ? "/home/ec2-user/playbook-jenkins-slave.yaml" : "empty.txt"
  }

   provisioner "file" {
    source =  each.key == "ansible-controller" ? "/Users/mahesh/Desktop/projects/eureka/eureka/terraform/playbook-sonar-install.yaml" : "empty.txt"
    destination = each.key == "ansible-controller" ? "/home/ec2-user/playbook-sonar-install.yaml" : "empty.txt"
  }

   provisioner "file" {
    source =  each.key == "ansible-controller" ? "/Users/mahesh/Desktop/projects/eureka/eureka/terraform/sonarqube.service" : "empty.txt"
    destination = each.key == "ansible-controller" ? "/home/ec2-user/sonarqube.service" : "empty.txt"
  }
    provisioner "file" {
      source      = each.key == "ansible-controller" ? "ansible.sh" : "empty.txt"
      destination = each.key == "ansible-controller" ? "/home/ec2-user/ansible.sh" : "empty.txt"
    }

    provisioner "file" {
      source      = each.key == "ansible-controller" ? "/Users/mahesh/Desktop/projects/eureka/eureka/terraform/playbook-docker-install.yaml" : "empty.txt"
      destination = each.key == "ansible-controller" ? "/home/ec2-user/playbook-docker-install.yaml" : "empty.txt"
    }

    provisioner "file" {
      source      = each.key == "ansible-controller" ? "/Users/mahesh/Desktop/projects/eureka/eureka/terraform/playbook-k8s.yaml" : "empty.txt"
      destination = each.key == "ansible-controller" ? "/home/ec2-user/playbook-k8s.yaml" : "empty.txt"
    }

    provisioner "remote-exec" {
    inline = each.key == "ansible-controller" ? [
      "chmod +x /home/ec2-user/ansible.sh",
      "sh /home/ec2-user/ansible.sh"
    ] : [
      "echo 'Skipped the Command'"
    ]
    }
/*
    provisioner "remote-exec" {
    inline = each.key == "ansible-controller" ? [
      "ansible-playbook -i hosts /home/ec2-user/playbook-jenkins-install-master.yaml >> /home/ec2-user/jenkins-install-master.log 2>&1" ,
      "ansible-playbook -i hosts /home/ec2-user/playbook-jenkins-slave.yaml >> /home/ec2-user/jenkins-slave.log 2>&1"
    ] : [
      "echo 'Skipped the Command'"
    ]
    }
*/
  tags = {
    "Name" = each.key
  }
}





/*
resource "null_resource" "generate-and-copy-hosts-file" {
  # Ensure this resource waits for outputs to be generated
  depends_on = [aws_instance.ec2]

  # Generate the 'hosts' file after outputs are created
  provisioner "local-exec" {
    command = <<EOT
terraform output instance_details | sed '/<<EOT/d;/EOT/d' > hosts
EOT
  }

  # Copy the 'hosts' file to the ansible-controller server
  provisioner "file" {
    source      = "hosts"
    destination = "/home/ec2-user/hosts"
    connection {
      type = "ssh"
      host        = aws_instance.ec2["ansible-controller"].public_ip
      user        = "ec2-user"
      private_key = file("~/.ssh/id_rsa")
    }
  }
}
*/




