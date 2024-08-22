pid_file = "./pidfile"
 
vault {
  address = "https://vault.dc.local"
  tls_skip_verify = true
  retry {
    num_retries = 5
  }
}
 
auto_auth {
  method "approle" {
    config = {
      role_id_file_path = "role_id"
      secret_id_file_path = "secret_id"
      remove_secret_id_file_after_reading = false
    }
  }

sink "file" {
  config = {
    path = ".agent-token"
  }
 }
}

# Template for generating  salt-master.conf file with accual token
# Template file /etc/salt/master.d/vault.conf.ctmpl creates  salt-manage formula

template {
  source = "/etc/vault.d/spring-boot-token.ctmpl"
  destination = "/etc/vault.d/spring-boot-token"
  # command = "salt-call state.apply spring-boot.restart_service"
}
