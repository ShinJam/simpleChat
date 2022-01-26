data "template_file" "userdata" {
  template = file("templates/userdata.sh")
}

data "template_file" "install_jenkins" {
  template = file("templates/install_jenkins.sh")
}

data "cloudinit_config" "init_jenkins" {
  # https://stackoverflow.com/questions/62067211/how-to-pass-multiple-template-files-to-user-data-variable-in-terraform
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    filename     = "userdata.sh"
    content      = data.template_file.userdata.rendered
  }

  part {
    content_type = "text/x-shellscript"
    filename     = "install_jenkins.sh"
    content      = data.template_file.install_jenkins.rendered
  }
}

