####################################################################

# Creating 3 EC2 Instances:

####################################################################

resource "aws_instance" "instance" {
  count                = length(aws_subnet.public_subnet.*.id)
  ami                  = var.ami_id
  instance_type        = var.instance_type
  subnet_id            = element(aws_subnet.public_subnet.*.id, count.index)
  security_groups      = [aws_security_group.sg.id, ]
  key_name             = "Keypair-01"
  iam_instance_profile = data.aws_iam_role.iam_role.name
  associate_public_ip_address = true

  /*user_data = <<-EOF
  #!/bin/bash
  echo "*** Installing apache2"
  sudo su
  yum update -y
  yum install httpd -y
  systemctl start httpd
  systemctl enable httpd
  echo "*** Completed Installing apache2"
  echo 'Welcome to Instance' >> /var/www/html/index.html
  sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
  systemctl restart sshd
  EOF*/

  tags = {
    "Name"        = "Instance-${count.index}"
    "Environment" = "Test"
    "CreatedBy"   = "Terraform"
  }

  timeouts {
    create = "10m"
  }

}

/* resource "null_resource" "null" {
  count = length(aws_subnet.public_subnet.*.id)

  provisioner "file" {
    source      = "./userdata.sh"
    destination = "/home/ec2-user/userdata.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ec2-user/userdata.sh",
      "sh /home/ec2-user/userdata.sh",
    ]
    on_failure = continue
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    port        = "22"
    host        = element(aws_eip.eip.*.public_ip, count.index)
    private_key = file(var.ssh_private_key)
  }

}*/



####################################################################

# Creating 3 Elastic IPs:

####################################################################

/* resource "aws_eip" "eip" {
  count            = length(aws_instance.instance.*.id)
  instance         = element(aws_instance.instance.*.id, count.index)
  public_ipv4_pool = "amazon"
  vpc              = true

  tags = {
    "Name" = "EIP-${count.index}"
  }
} */

####################################################################

# Creating EIP association with EC2 Instances:

####################################################################

/* resource "aws_eip_association" "eip_association" {
  count         = length(aws_eip.eip)
  instance_id   = element(aws_instance.instance.*.id, count.index)
  allocation_id = element(aws_eip.eip.*.id, count.index)
}  */

resource "local_file" "host_inventory" {
  content  = <<EOT
  [all]
  %{for ip in aws_instance.instance.*.public_ip[*] ~} 
  ${ip}
  %{endfor ~} 
  EOT
  filename = "ansible/inventories/dev/host-inventory"
}