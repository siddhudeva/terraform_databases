/// null resource is actually will not do anything but it implements the standard resource lifecycle
///null resource equippeed with provisioner == provisioner is used to ecexute the commands in local and remote level and it also have a file provisioner that is used to copy files from local machine to remote machine.
resource "null_resource" "db-deploy" {
  triggers = {
    instance_ids = aws_spot_instance_request.DB.spot_instance_id
  }
  provisioner "remote-exec" {
  connection { /////using provided connection details like credentials which is going to login and execute shell commands
    type     = "ssh"
    user     = var.SSH_USERNAME
    password = var.SSH_PASSWORD
    host     = aws_spot_instance_request.DB.private_ip
  }
    inline = [
      "ansible-pull -U https://github.com/siddhudeva/ansible-1.git roboshop-pull.yml -e COMPONENT=${var.DB_COMPONENT} -e ENV = ${var.ENV}"
    ]
  }
}
