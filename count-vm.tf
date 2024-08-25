data "yandex_compute_image" "ubuntu-2004-lts" {
  family = "ubuntu-2004-lts"
}

resource "yandex_compute_instance" "example" {
  count = var.count_vm.count
  depends_on = [yandex_compute_instance.second]
  name        = "${var.count_vm.name}-${count.index + 1}"
  platform_id = var.count_vm.platform_id

  resources {
    cores         = var.count_vm.cores
    memory        = var.count_vm.memory
    core_fraction = var.count_vm.core_fraction
    
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-2004-lts.image_id
      type     = var.vm_disks_cuontvm.type
      size     = var.vm_disks_cuontvm.size
    }
  }

  metadata = local.vms_metadata

  

   scheduling_policy { preemptible = var.sh_pol }

  network_interface {

    subnet_id          = yandex_vpc_subnet.develop.id
    security_group_ids = [yandex_vpc_security_group.example.id]
    nat                = var.vm_nat
  }
  
  allow_stopping_for_update = var.allow_stopping
}