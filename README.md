# Домашнее задание к занятию «Управляющие конструкции в коде Terraform»-Абрамов Сергей

### Цели задания

1. Отработать основные принципы и методы работы с управляющими конструкциями Terraform.
2. Освоить работу с шаблонизатором Terraform (Interpolation Syntax).

------

### Чек-лист готовности к домашнему заданию

1. Зарегистрирован аккаунт в Yandex Cloud. Использован промокод на грант.
2. Установлен инструмент Yandex CLI.
3. Доступен исходный код для выполнения задания в директории [**03/src**](https://github.com/netology-code/ter-homeworks/tree/main/03/src).
4. Любые ВМ, использованные при выполнении задания, должны быть прерываемыми, для экономии средств.

------

### Внимание!! Обязательно предоставляем на проверку получившийся код в виде ссылки на ваш github-репозиторий!
Убедитесь что ваша версия **Terraform** ~>1.8.4
Теперь пишем красивый код, хардкод значения не допустимы!
------

### Задание 1

1. Изучите проект.
2. Заполните файл personal.auto.tfvars.
3. Инициализируйте проект, выполните код. Он выполнится, даже если доступа к preview нет.

Примечание. Если у вас не активирован preview-доступ к функционалу «Группы безопасности» в Yandex Cloud, запросите доступ у поддержки облачного провайдера. Обычно его выдают в течение 24-х часов.

Приложите скриншот входящих правил «Группы безопасности» в ЛК Yandex Cloud или скриншот отказа в предоставлении доступа к preview-версии.

------

### Решение

![1](https://github.com/smabramov/Terraform-hw-03/blob/248c579ef7f9b72d373f5711ec4cf45c237e1644/jpeg/1.png)

### Задание 2

1. Создайте файл count-vm.tf. Опишите в нём создание двух **одинаковых** ВМ  web-1 и web-2 (не web-0 и web-1) с минимальными параметрами, используя мета-аргумент **count loop**. Назначьте ВМ созданную в первом задании группу безопасности.(как это сделать узнайте в документации провайдера yandex/compute_instance )
2. Создайте файл for_each-vm.tf. Опишите в нём создание двух ВМ для баз данных с именами "main" и "replica" **разных** по cpu/ram/disk_volume , используя мета-аргумент **for_each loop**. Используйте для обеих ВМ одну общую переменную типа:
```
variable "each_vm" {
  type = list(object({  vm_name=string, cpu=number, ram=number, disk_volume=number }))
}
```  
При желании внесите в переменную все возможные параметры.
4. ВМ из пункта 2.1 должны создаваться после создания ВМ из пункта 2.2.
5. Используйте функцию file в local-переменной для считывания ключа ~/.ssh/id_rsa.pub и его последующего использования в блоке metadata, взятому из ДЗ 2.
6. Инициализируйте проект, выполните код.

------

### Решение

Файл [count-vm.tf](https://github.com/smabramov/Terraform-hw-03/blob/85b34d394a8fe9737c491498c0d763e87bcb942e/count-vm.tf)

```
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

```
![2](https://github.com/smabramov/Terraform-hw-03/blob/85b34d394a8fe9737c491498c0d763e87bcb942e/jpeg/2.png)

Файл [for_each-vm.tf](https://github.com/smabramov/Terraform-hw-03/blob/85b34d394a8fe9737c491498c0d763e87bcb942e/for_each-vm.tf) и переменая each_vm в [variables.tf](https://github.com/smabramov/Terraform-hw-03/blob/85b34d394a8fe9737c491498c0d763e87bcb942e/variables.tf)

```
resource "yandex_compute_instance" "second" {
  for_each = toset (keys({for i, r in var.each_vm:  i => r}) )
  
name = var.each_vm[each.value]["vm_name"]

   resources {
    cores         = var.each_vm[each.value]["cpu"]
    memory        = var.each_vm[each.value]["ram"]
    core_fraction = var.each_vm[each.value]["core_fraction"]
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-2004-lts.image_id
      type     = var.vm_disks_cuontvm.type
      size     =  var.each_vm[each.value]["disk_volume"]
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

```

```
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

```

Добавим в [count-vm.tf](https://github.com/smabramov/Terraform-hw-03/blob/85b34d394a8fe9737c491498c0d763e87bcb942e/count-vm.tf) атрибут depends_on = [yandex_compute_instance.second], чтобы данный ресурс создавался после вторых ВМ

Файл [locals.tf](https://github.com/smabramov/Terraform-hw-03/blob/85b34d394a8fe9737c491498c0d763e87bcb942e/locals.tf)

```
locals {
  ssh = "${"ubuntu"}:${file("~/.ssh/id_ed25519.pub")}"
}

```

![3](https://github.com/smabramov/Terraform-hw-03/blob/85b34d394a8fe9737c491498c0d763e87bcb942e/jpeg/3.png)


### Задание 3

1. Создайте 3 одинаковых виртуальных диска размером 1 Гб с помощью ресурса yandex_compute_disk и мета-аргумента count в файле **disk_vm.tf** .
2. Создайте в том же файле **одиночную**(использовать count или for_each запрещено из-за задания №4) ВМ c именем "storage"  . Используйте блок **dynamic secondary_disk{..}** и мета-аргумент for_each для подключения созданных вами дополнительных дисков.

------

### Решение

![4](https://github.com/smabramov/Terraform-hw-03/blob/85b34d394a8fe9737c491498c0d763e87bcb942e/jpeg/4.png)

![5](https://github.com/smabramov/Terraform-hw-03/blob/85b34d394a8fe9737c491498c0d763e87bcb942e/jpeg/5.png)

### Задание 4

1. В файле ansible.tf создайте inventory-файл для ansible.
Используйте функцию tepmplatefile и файл-шаблон для создания ansible inventory-файла из лекции.
Готовый код возьмите из демонстрации к лекции [**demonstration2**](https://github.com/netology-code/ter-homeworks/tree/main/03/demo).
Передайте в него в качестве переменных группы виртуальных машин из задания 2.1, 2.2 и 3.2, т. е. 5 ВМ.
2. Инвентарь должен содержать 3 группы и быть динамическим, т. е. обработать как группу из 2-х ВМ, так и 999 ВМ.
3. Добавьте в инвентарь переменную  [**fqdn**](https://cloud.yandex.ru/docs/compute/concepts/network#hostname).
``` 
[webservers]
web-1 ansible_host=<внешний ip-адрес> fqdn=<полное доменное имя виртуальной машины>
web-2 ansible_host=<внешний ip-адрес> fqdn=<полное доменное имя виртуальной машины>

[databases]
main ansible_host=<внешний ip-адрес> fqdn=<полное доменное имя виртуальной машины>
replica ansible_host<внешний ip-адрес> fqdn=<полное доменное имя виртуальной машины>

[storage]
storage ansible_host=<внешний ip-адрес> fqdn=<полное доменное имя виртуальной машины>
```
Пример fqdn: ```web1.ru-central1.internal```(в случае указания переменной hostname(не путать с переменной name)); ```fhm8k1oojmm5lie8i22a.auto.internal```(в случае отсутвия перменной hostname - автоматическая генерация имени,  зона изменяется на auto). нужную вам переменную найдите в документации провайдера или terraform console.
4. Выполните код. Приложите скриншот получившегося файла. 

Для общего зачёта создайте в вашем GitHub-репозитории новую ветку terraform-03. Закоммитьте в эту ветку свой финальный код проекта, пришлите ссылку на коммит.   
**Удалите все созданные ресурсы**.

### Решение
Файлы:
[inventory.tftpl](https://github.com/smabramov/Terraform-hw-03/blob/85b34d394a8fe9737c491498c0d763e87bcb942e/inventory.tftpl)
[ansible.tf](https://github.com/smabramov/Terraform-hw-03/blob/85b34d394a8fe9737c491498c0d763e87bcb942e/ansible.tf)
[test.yaml](https://github.com/smabramov/Terraform-hw-03/blob/85b34d394a8fe9737c491498c0d763e87bcb942e/test.yaml)

 Получившийся файл  inventory.cfg

![6](https://github.com/smabramov/Terraform-hw-03/blob/85b34d394a8fe9737c491498c0d763e87bcb942e/jpeg/6.png)

------

## Дополнительные задания (со звездочкой*)

**Настоятельно рекомендуем выполнять все задания со звёздочкой.** Они помогут глубже разобраться в материале.   
Задания со звёздочкой дополнительные, не обязательные к выполнению и никак не повлияют на получение вами зачёта по этому домашнему заданию. 

### Задание 5* (необязательное)
1. Напишите output, который отобразит ВМ из ваших ресурсов count и for_each в виде списка словарей :
``` 
[
 {
  "name" = 'имя ВМ1'
  "id"   = 'идентификатор ВМ1'
  "fqdn" = 'Внутренний FQDN ВМ1'
 },
 {
  "name" = 'имя ВМ2'
  "id"   = 'идентификатор ВМ2'
  "fqdn" = 'Внутренний FQDN ВМ2'
 },
 ....
...итд любое количество ВМ в ресурсе(те требуется итерация по ресурсам, а не хардкод) !!!!!!!!!!!!!!!!!!!!!
]
```
Приложите скриншот вывода команды ```terrafrom output```.

------

### Задание 6* (необязательное)

1. Используя null_resource и local-exec, примените ansible-playbook к ВМ из ansible inventory-файла.
Готовый код возьмите из демонстрации к лекции [**demonstration2**](https://github.com/netology-code/ter-homeworks/tree/main/03/demo).
3. Модифицируйте файл-шаблон hosts.tftpl. Необходимо отредактировать переменную ```ansible_host="<внешний IP-address или внутренний IP-address если у ВМ отсутвует внешний адрес>```.

Для проверки работы уберите у ВМ внешние адреса(nat=false). Этот вариант используется при работе через bastion-сервер.
Для зачёта предоставьте код вместе с основной частью задания.

### Правила приёма работы

В своём git-репозитории создайте новую ветку terraform-03, закоммитьте в эту ветку свой финальный код проекта. Ответы на задания и необходимые скриншоты оформите в md-файле в ветке terraform-03.

В качестве результата прикрепите ссылку на ветку terraform-03 в вашем репозитории.

Важно. Удалите все созданные ресурсы.

### Задание 7* (необязательное)
Ваш код возвращает вам следущий набор данных: 
```
> local.vpc
{
  "network_id" = "enp7i560tb28nageq0cc"
  "subnet_ids" = [
    "e9b0le401619ngf4h68n",
    "e2lbar6u8b2ftd7f5hia",
    "b0ca48coorjjq93u36pl",
    "fl8ner8rjsio6rcpcf0h",
  ]
  "subnet_zones" = [
    "ru-central1-a",
    "ru-central1-b",
    "ru-central1-c",
    "ru-central1-d",
  ]
}
```
Предложите выражение в terraform console, которое удалит из данной переменной 3 элемент из: subnet_ids и subnet_zones.(значения могут быть любыми) Образец конечного результата:
```
> <некое выражение>
{
  "network_id" = "enp7i560tb28nageq0cc"
  "subnet_ids" = [
    "e9b0le401619ngf4h68n",
    "e2lbar6u8b2ftd7f5hia",
    "fl8ner8rjsio6rcpcf0h",
  ]
  "subnet_zones" = [
    "ru-central1-a",
    "ru-central1-b",
    "ru-central1-d",
  ]
}
```
### Задание 8* (необязательное)
Идентифицируйте и устраните намеренно допущенную в tpl-шаблоне ошибку. Обратите внимание, что terraform сам сообщит на какой строке и в какой позиции ошибка!
```
[webservers]
%{~ for i in webservers ~}
${i["name"]} ansible_host=${i["network_interface"][0]["nat_ip_address"] platform_id=${i["platform_id "]}}
%{~ endfor ~}
```

### Критерии оценки

Зачёт ставится, если:

* выполнены все задания,
* ответы даны в развёрнутой форме,
* приложены соответствующие скриншоты и файлы проекта,
* в выполненных заданиях нет противоречий и нарушения логики.

На доработку работу отправят, если:

* задание выполнено частично или не выполнено вообще,
* в логике выполнения заданий есть противоречия и существенные недостатки. 


