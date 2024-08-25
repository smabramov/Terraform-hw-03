resource "local_file" "inventory_cfg" {
  content = templatefile("${path.module}/inventory.tftpl",
    { 
    webservers =  yandex_compute_instance.example,
    databases =  yandex_compute_instance.second, 
    storage =  [yandex_compute_instance.storage]   
   # fqdn =  
    }  
)

  filename = "${abspath(path.module)}/inventory.cfg"
}
