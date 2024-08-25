
variable "cloud_id" {
  type        = string
  default     = "b1gttf81lmg2v759uobi"
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  default     = "b1g8381i07tsfq06pnmc"
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}

variable "public_key" {
  type    = string
  default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGxDA6ZQM1u1nDL0NqZz/rgrzGd5zbrbWKV3xuFp29zL serg@ubuntu"

}
variable "count_vm" {
  default = { name = "web", cores = 2, memory = 1, core_fraction = 20,  platform_id = "standard-v1", count = 2}
}

variable "each_vm" {
  description = "eachvm_parameters"
  type = list(object({
    vm_name     = string,
    cpu         = number,
    ram         = number,
    disk_volume = number,
    core_fraction = number
  }))
  default = [ {
    vm_name     = "main"
    cpu         = 4
    ram         = 2
    disk_volume = 5
    core_fraction = 5

    },
    {
      vm_name     = "replica"
      cpu         = 2
      ram         = 1
      disk_volume = 8
      core_fraction = 5
  }]
}
variable "web_provision" {
  type    = bool
  default = true
  description="ansible provision switch variable"
}
variable "vm_storage" {
  type = map
  default = {
name = "storage"
cores = 2
memory = 1 
core_fraction = 5
  }
  }
  variable "vm_nat" {
  type = bool
  default = true
  }
  
  variable "vm_disks_stor" {
    type = map
  default = {
  count   = 3
  name  = "disk"
  type = "network-hdd"
  size  = 1
  }
  }
   variable "vm_disks_cuontvm" {
    type = map
  default = {
  type = "network-hdd"
  size  = 5

  }
}
variable "sh_pol" {
 default = true
}
variable "allow_stopping" {
  default = true
}