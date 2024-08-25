resource "yandex_compute_disk" "disks" {
  count   = var.vm_disks_stor.count
  name  = "${var.vm_disks_stor.name}-${count.index + 1}"
  type = var.vm_disks_stor.type
  size  = var.vm_disks_stor.size

}


resource "yandex_compute_instance" "storage" {
  name = var.vm_storage.name
  resources {
    cores = var.vm_storage.cores
    memory = var.vm_storage.memory
    core_fraction = var.vm_storage.core_fraction
  }

  boot_disk {
    initialize_params {
    image_id = data.yandex_compute_image.ubuntu-2004-lts.image_id
        }
  }

  dynamic "secondary_disk" {
   for_each =  yandex_compute_disk.disks
     content {

     disk_id = secondary_disk.value.id
     
   }
  }
  scheduling_policy { preemptible = var.sh_pol }
  network_interface {
     subnet_id = yandex_vpc_subnet.develop.id
     nat     = var.vm_nat
  }
 allow_stopping_for_update = var.allow_stopping
  metadata = local.vms_metadata
}