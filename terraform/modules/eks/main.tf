resource "local_file" "cluster_template"{
  content = var.cluster_config_values
  filename = var.filename
}
