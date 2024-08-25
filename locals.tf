locals{
    vms_metadata = {
      serial-port-enable = 1
      ssh-key  = "ubuntu:${file("~/.ssh/id_ed25519.pub")} " 
    }
}