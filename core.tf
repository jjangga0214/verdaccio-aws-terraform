resource "random_string" "ssh_keys" {
  length  = 24
  special = false
  keepers = {
    # Generate a new id each time we switch to a new AMI id
    ssh_public_key    = "${file(var.ssh_public_key_path)}"
    ssh_private_key   = "${file(var.ssh_private_key_path)}"
    aws_key_pair_name = var.aws_key_pair_name
  }
}

resource "aws_key_pair" "key_pair" {
  key_name = "${random_string.ssh_keys.keepers.aws_key_pair_name}-${random_string.ssh_keys.result}"
  # Read the public_key "through" the random_string resource to ensure that
  # both will change together.
  public_key = "${random_string.ssh_keys.keepers.ssh_public_key}"
}

resource "aws_instance" "verdaccio_server" {
  ami                         = var.aws_amis[var.aws_region]
  instance_type               = var.aws_instance_type
  subnet_id                   = "${aws_subnet.subnet.id}"
  vpc_security_group_ids      = ["${aws_security_group.allow_verdaccio.id}", "${aws_security_group.allow_basic.id}"]
  associate_public_ip_address = "true"
  key_name                    = "${aws_key_pair.key_pair.key_name}"

  tags = {
    Name  = "verdaccio-server"
  }

  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = "${random_string.ssh_keys.keepers.ssh_private_key}"
    host        = "${aws_instance.verdaccio_server.public_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir /verdaccio",
      "sudo chown -hR $USER:$USER /verdaccio",
      "sudo chmod -R 777 /verdaccio"
    ]
  }

  provisioner "file" {
    # trailing slash("/") matters. [ref](https://www.terraform.io/docs/provisioners/file.html#directory-uploads)
    source      = "docker/"
    destination = "/verdaccio"
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /verdaccio/docker-install.sh",
      "sudo /verdaccio/docker-install.sh",
      "sudo docker-compose --project-name verdaccio --file /verdaccio/docker-compose.yml up -d",
    ]
  }
}
