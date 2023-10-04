resource "shoreline_notebook" "slowloris_attack_detected_on_apache_server" {
  name       = "slowloris_attack_detected_on_apache_server"
  data       = file("${path.module}/data/slowloris_attack_detected_on_apache_server.json")
  depends_on = [shoreline_action.invoke_apache_max_connections,shoreline_action.invoke_install_mod_evasive]
}

resource "shoreline_file" "apache_max_connections" {
  name             = "apache_max_connections"
  input_file       = "${path.module}/data/apache_max_connections.sh"
  md5              = filemd5("${path.module}/data/apache_max_connections.sh")
  description      = "Configure the Apache server to limit the number of connections from a single IP address."
  destination_path = "/agent/scripts/apache_max_connections.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "install_mod_evasive" {
  name             = "install_mod_evasive"
  input_file       = "${path.module}/data/install_mod_evasive.sh"
  md5              = filemd5("${path.module}/data/install_mod_evasive.sh")
  description      = "Install a rate-limiting module on the server to prevent excessive requests from any single IP address."
  destination_path = "/agent/scripts/install_mod_evasive.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_apache_max_connections" {
  name        = "invoke_apache_max_connections"
  description = "Configure the Apache server to limit the number of connections from a single IP address."
  command     = "`chmod +x /agent/scripts/apache_max_connections.sh && /agent/scripts/apache_max_connections.sh`"
  params      = ["PATH_TO_APACHE_CONF_FILE","MAX_CONNECTIONS_PER_IP"]
  file_deps   = ["apache_max_connections"]
  enabled     = true
  depends_on  = [shoreline_file.apache_max_connections]
}

resource "shoreline_action" "invoke_install_mod_evasive" {
  name        = "invoke_install_mod_evasive"
  description = "Install a rate-limiting module on the server to prevent excessive requests from any single IP address."
  command     = "`chmod +x /agent/scripts/install_mod_evasive.sh && /agent/scripts/install_mod_evasive.sh`"
  params      = []
  file_deps   = ["install_mod_evasive"]
  enabled     = true
  depends_on  = [shoreline_file.install_mod_evasive]
}

