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


resource "random_password" "each" {
  for_each    = toset([for k, v in yandex_compute_instance.example : v.name ])
  length = 17
#> type(random_password.each) object(object)
}

resource "null_resource" "web_hosts_provision" {
#Ждем создания инстанса
depends_on = [yandex_compute_instance.storage, local_file.inventory_cfg]


#Костыль!!! Даем ВМ 60 сек на первый запуск. Лучше выполнить это через wait_for port 22 на стороне ansible
# В случае использования cloud-init может потребоваться еще больше времени
 provisioner "local-exec" {
    command = "sleep 60"
  }

#Запуск ansible-playbook
  provisioner "local-exec" {                  
   # command  = "export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -i ${abspath(path.module)}/inventory.cfg ${abspath(path.module)}/test.yaml"
    command     = "export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -i ${abspath(path.module)}/hosts.cfg ${abspath(path.module)}/test.yaml --extra-vars '{\"secrets\": ${jsonencode( {for k,v in random_password.each: k=>v.result})} }'"
    on_failure = continue #Продолжить выполнение terraform pipeline в случае ошибок
    #environment = { ANSIBLE_HOST_KEY_CHECKING = "False" }
    #срабатывание триггера при изменении переменных
  }
    triggers = {  
#всегда т.к. дата и время постоянно изменяются
      always_run         = "${timestamp()}" 
 # при изменении содержимого playbook файла
      playbook_src_hash  = file("${path.module}/test.yaml") 
      ssh_public_key     = var.public_key # при изменении переменной
    }

}