terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "slowloris_attack_detected_on_apache_server" {
  source    = "./modules/slowloris_attack_detected_on_apache_server"

  providers = {
    shoreline = shoreline
  }
}