terraform {
  required_providers {
    vkcs = {
      source  = "hub.mcs.mail.ru/repository/vkcs"
    }
  }
}

provider "vkcs" {
    username   = "atomsmuzi@mail.ru"
    password   = "SmuziBeer!"
    project_id = "5565babd88134a32b89e10cd95cd613f"
  }


### Сеть
## Создание сети
resource "vkcs_networking_network" "new_network_01" {
    name           = "new_network_01"
}

## Создание подсети
# Подсеть 01
resource "vkcs_networking_subnet" "new_subnet_01" {
  name       = "new_subnet_01"
  network_id = "${vkcs_networking_network.new_network_01.id}"
  cidr       = "10.10.10.0/24"
  ip_version = 4
}

# Подсеть 02
#resource "vkcs_networking_subnet" "new_subnet_02" {
#  name       = "new_subnet_02"
#  network_id = "${vkcs_networking_network.new_network_01.id}"
#  cidr       = "10.10.20.0/24"
#  ip_version = 4
#}

# Создаем роутер
resource "vkcs_networking_router" "router_01" {
  name                = "router_01"
  admin_state_up      = true
  external_network_id = "298117ae-3fa4-4109-9e08-8be5602be5a2"
}

# Создаем интерфейс роутера
resource "vkcs_networking_router_interface" "router_interface_subnet_01" {
  router_id = "${vkcs_networking_router.router_01.id}"
  subnet_id = "${vkcs_networking_subnet.new_subnet_01.id}"
}
# Второй интерфейс роутера
#resource "vkcs_networking_router_interface" "router_interface_subnet_02" {
#  router_id = "${vkcs_networking_router.router_01.id}"
#  subnet_id = "${vkcs_networking_subnet.new_subnet_02.id}"
#}

## Внешние адреса
# Внешний адрес для vm_app_01
resource "vkcs_networking_floatingip" "ext_ip_vm_app_01" {
  pool = "ext-net"
}

# Внешний адрес для vm_app_02
resource "vkcs_networking_floatingip" "ext_ip_vm_app_02" {
  pool = "ext-net"
}

# Внешний адрес для vm_app_03
#resource "vkcs_networking_floatingip" "ext_ip_vm_app_03" {
#  pool = "ext-net"
#}

# Внешний адрес для vm_web_02
resource "vkcs_networking_floatingip" "ext_ip_vm_web_02" {
  pool = "ext-net"
}

# Внешний адрес для vm_web_01
resource "vkcs_networking_floatingip" "ext_ip_vm_web_01" {
  pool = "ext-net"
}


## Привязка внешних адресов к виртуальным машинам
# NAT для vm_web_01
resource "vkcs_compute_floatingip_associate" "nat_vm_web_01" {
  floating_ip = "${vkcs_networking_floatingip.ext_ip_vm_web_01.address}"
  instance_id = "${vkcs_compute_instance.vm_web_01.id}"
  fixed_ip    = "${vkcs_compute_instance.vm_web_01.network[0].fixed_ip_v4}"
}

# NAT для vm_app_01
resource "vkcs_compute_floatingip_associate" "nat_vm_app_01" {
  floating_ip = "${vkcs_networking_floatingip.ext_ip_vm_app_01.address}"
  instance_id = "${vkcs_compute_instance.vm_app_01.id}"
  fixed_ip    = "${vkcs_compute_instance.vm_app_01.network[0].fixed_ip_v4}"
}

# NAT для vm_app_02
resource "vkcs_compute_floatingip_associate" "nat_vm_app_02" {
  floating_ip = "${vkcs_networking_floatingip.ext_ip_vm_app_02.address}"
  instance_id = "${vkcs_compute_instance.vm_app_02.id}"
  fixed_ip    = "${vkcs_compute_instance.vm_app_02.network[0].fixed_ip_v4}"
}

# NAT для vm_app_03
#resource "vkcs_compute_floatingip_associate" "nat_vm_app_03" {
#  floating_ip = "${vkcs_networking_floatingip.ext_ip_vm_app_03.address}"
#  instance_id = "${vkcs_compute_instance.vm_app_03.id}"
#  fixed_ip    = "${vkcs_compute_instance.vm_app_03.network[0].fixed_ip_v4}"
#}

# NAT для vm_web_02
resource "vkcs_compute_floatingip_associate" "nat_vm_web_02" {
  floating_ip = "${vkcs_networking_floatingip.ext_ip_vm_web_02.address}"
  instance_id = "${vkcs_compute_instance.vm_web_02.id}"
  fixed_ip    = "${vkcs_compute_instance.vm_web_02.network[0].fixed_ip_v4}"
}

### Порты для виртуальных машин
# порт для машины vm_app_01
resource "vkcs_networking_port" "port_vm_app_01" {
  name               = "port_vm_app_01"
  network_id         = "${vkcs_networking_network.new_network_01.id}"
  admin_state_up     = "true"
  security_group_ids = ["${vkcs_networking_secgroup.security_group_app.id}"]
  fixed_ip {
    subnet_id  = "${vkcs_networking_subnet.new_subnet_01.id}"
    ip_address = "10.10.10.10"
  }
}

# порт для машины vm_app_02
resource "vkcs_networking_port" "port_vm_app_02" {
  name               = "port_vm_app_02"
  network_id         = "${vkcs_networking_network.new_network_01.id}"
  admin_state_up     = "true"
  security_group_ids = ["${vkcs_networking_secgroup.security_group_app.id}"]
  fixed_ip {
    subnet_id  = "${vkcs_networking_subnet.new_subnet_01.id}"
    ip_address = "10.10.10.20"
  }
}

# порт для машины vm_web_01
resource "vkcs_networking_port" "port_vm_web_01" {
  name               = "port_vm_web_01"
  network_id         = "${vkcs_networking_network.new_network_01.id}"
  admin_state_up     = "true"
  security_group_ids = ["${vkcs_networking_secgroup.security_group_web.id}"]
  fixed_ip {
    subnet_id  = "${vkcs_networking_subnet.new_subnet_01.id}"
    ip_address = "10.10.10.100"
  }
}

# порт для машины vm_app_03
#resource "vkcs_networking_port" "port_vm_app_03" {
#  name               = "port_vm_app_03"
#  network_id         = "${vkcs_networking_network.new_network_01.id}"
#  admin_state_up     = "true"
#  security_group_ids = ["${vkcs_networking_secgroup.security_group_01.id}"]
#  fixed_ip {
#    subnet_id  = "${vkcs_networking_subnet.new_subnet_01.id}"
#    ip_address = "10.10.10.30"
#  }
#}

# порт для машины vm_web_02
resource "vkcs_networking_port" "port_vm_web_02" {
  name               = "port_vm_web_02"
  network_id         = "${vkcs_networking_network.new_network_01.id}"
  admin_state_up     = "true"
  security_group_ids = ["${vkcs_networking_secgroup.security_group_web.id}"]
  fixed_ip {
    subnet_id  = "${vkcs_networking_subnet.new_subnet_01.id}"
    ip_address = "10.10.10.150"
  }
}

# порт для машины vm_web2_01
#resource "vkcs_networking_port" "port_vm_web2_01" {
#  name               = "port_vm_web2_01"
#  network_id         = "${vkcs_networking_network.new_network_01.id}"
#  admin_state_up     = "true"
#  security_group_ids = ["${vkcs_networking_secgroup.security_group_01.id}"]
#  fixed_ip {
#    subnet_id  = "${vkcs_networking_subnet.new_subnet_02.id}"
#    ip_address = "10.10.20.100"
#  }
#}

### Безопасноть

## Группа безопасности (файерволл) для WEB серверов
resource "vkcs_networking_secgroup" "security_group_web" {
  name        = "security_group_web"
}

## Группа безопасности (файерволл) для APP серверов
resource "vkcs_networking_secgroup" "security_group_app" {
  name        = "security_group_app"
}

## Правила для группы безопасности WEB
# Разрешаем ssh
resource "vkcs_networking_secgroup_rule" "allow_ssh_web" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${vkcs_networking_secgroup.security_group_web.id}"
}

# Разрешаем http
resource "vkcs_networking_secgroup_rule" "allow_http_web" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${vkcs_networking_secgroup.security_group_web.id}"
}

# Разрешаем https
resource "vkcs_networking_secgroup_rule" "allow_https_web" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${vkcs_networking_secgroup.security_group_web.id}"
}

# Разрешаем icmp
resource "vkcs_networking_secgroup_rule" "allow_ping_web" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${vkcs_networking_secgroup.security_group_web.id}"
}

## Правила для группы безопасности APP
# Разрешаем icmp
resource "vkcs_networking_secgroup_rule" "allow_ping_app" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${vkcs_networking_secgroup.security_group_app.id}"
}

# Разрешаем ssh
resource "vkcs_networking_secgroup_rule" "allow_ssh_app" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${vkcs_networking_secgroup.security_group_app.id}"
}

## Привязка группы безопасности к портам VM
# Привязка к vm_app_01
resource "vkcs_networking_port_secgroup_associate" "assosiation_vm_app_01" {
  port_id = "${vkcs_networking_port.port_vm_app_01.id}"
  security_group_ids = [
    "${vkcs_networking_secgroup.security_group_app.id}",
  ]
}

# Привязка к vm_app_02
resource "vkcs_networking_port_secgroup_associate" "assosiation_vm_app_02" {
  port_id = "${vkcs_networking_port.port_vm_app_02.id}"
  security_group_ids = [
    "${vkcs_networking_secgroup.security_group_app.id}",
  ]
}

# Привязка к vm_app_03
#resource "vkcs_networking_port_secgroup_associate" "assosiation_vm_app_03" {
#  port_id = "${vkcs_networking_port.port_vm_app_03.id}"
#  security_group_ids = [
#    "${vkcs_networking_secgroup.security_group_01.id}",
#  ]
#}

# Привязка к vm_web_02
resource "vkcs_networking_port_secgroup_associate" "assosiation_vm_web_02" {
  port_id = "${vkcs_networking_port.port_vm_web_02.id}"
  security_group_ids = [
    "${vkcs_networking_secgroup.security_group_web.id}",
  ]
}

# Привязка к vm_web_01
resource "vkcs_networking_port_secgroup_associate" "assosiation_vm_web_01" {
  port_id = "${vkcs_networking_port.port_vm_web_01.id}"
  security_group_ids = [
    "${vkcs_networking_secgroup.security_group_web.id}",
  ]
}

### Виртуальные машины
## vm_app_01
resource "vkcs_compute_instance" "vm_app_01" {
  name            = "vm_app_01"
  image_id        = "024f4129-5fc9-43c5-8f64-946859e20e5c"
  flavor_id       = "d659fa16-c7fb-42cf-8a5e-9bcbe80a7538"
  user_data = file("cloud_init.cfg")
  network {
    port = "${vkcs_networking_port.port_vm_app_01.id}"
  }
}

# vm_app_02
resource "vkcs_compute_instance" "vm_app_02" {
  name            = "vm_app_02"
  image_id        = "024f4129-5fc9-43c5-8f64-946859e20e5c"
  flavor_id       = "d659fa16-c7fb-42cf-8a5e-9bcbe80a7538"
  user_data = file("cloud_init.cfg")
  network {
    port = "${vkcs_networking_port.port_vm_app_02.id}"
  }
}

# vm_app_03
#resource "vkcs_compute_instance" "vm_app_03" {
#  name            = "vm_app_03"
#  image_id        = "024f4129-5fc9-43c5-8f64-946859e20e5c"
#  flavor_id       = "d659fa16-c7fb-42cf-8a5e-9bcbe80a7538"
#  user_data = file("cloud_init.cfg")
#  network {
#    port = "${vkcs_networking_port.port_vm_app_03.id}"
#  }
#}

# vm_web_02
resource "vkcs_compute_instance" "vm_web_02" {
  name            = "vm_web_02"
  image_id        = "024f4129-5fc9-43c5-8f64-946859e20e5c"
  flavor_id       = "d659fa16-c7fb-42cf-8a5e-9bcbe80a7538"
  user_data = file("cloud_init.cfg")
  network {
    port = "${vkcs_networking_port.port_vm_web_02.id}"
  }
}

# vm_web_01
resource "vkcs_compute_instance" "vm_web_01" {
  name            = "vm_web_01"
  image_id        = "024f4129-5fc9-43c5-8f64-946859e20e5c"
  flavor_id       = "d659fa16-c7fb-42cf-8a5e-9bcbe80a7538"
  user_data = file("cloud_init.cfg")
  network {
    port = "${vkcs_networking_port.port_vm_web_01.id}"
  }
}


# vm_web2_01
#resource "vkcs_compute_instance" "vm_web2_01" {
#  name            = "vm_web2_01"
#  image_id        = "024f4129-5fc9-43c5-8f64-946859e20e5c"
#  flavor_id       = "d659fa16-c7fb-42cf-8a5e-9bcbe80a7538"
#  user_data = file("cloud_init.cfg")
#  network {
#    port = "${vkcs_networking_port.port_vm_web2_01.id}"
#  }
#}

### Информация о машинах
## vm_app_01
output "vm_app_01" {
  value = vkcs_networking_floatingip.ext_ip_vm_app_01.address
}


## vm_app_02
output "vm_app_02" {
  value = vkcs_networking_floatingip.ext_ip_vm_app_02.address
}

## vm_app_03
#output "vm_app_03" {
#  value = vkcs_networking_floatingip.ext_ip_vm_app_03.address
#}

## vm_web_02
output "vm_web_02" {
  value = vkcs_networking_floatingip.ext_ip_vm_web_02.address
}

## vm_web_01
output "vm_web_01" {
  value = vkcs_networking_floatingip.ext_ip_vm_web_01.address
}


### Балансировщик
## Порт для балансировщика
resource "vkcs_networking_port" "port_lb" {
  name               = "port_lb"
  network_id         = "${vkcs_networking_network.new_network_01.id}"
  admin_state_up     = "true"
  security_group_ids = ["${vkcs_networking_secgroup.security_group_web.id}"]
  fixed_ip {
    subnet_id  = "${vkcs_networking_subnet.new_subnet_01.id}"
    ip_address = "10.10.10.200"
  }
}

## Внешний адрес для балансировщика
resource "vkcs_networking_floatingip" "ext_ip_lb" {
  pool = "ext-net"
}

## NAT для балансировщика
resource "vkcs_networking_floatingip_associate" "assosiaion_lb" {
  floating_ip = "${vkcs_networking_floatingip.ext_ip_lb.address}"
  port_id     = "${vkcs_networking_port.port_lb.id}"
  depends_on = [
    vkcs_networking_port.port_lb
  ]
}

## Создаем балансировщик
resource "vkcs_lb_loadbalancer" "loadbalancer" {
  name = "loadbalancer"
  vip_subnet_id = "${vkcs_networking_subnet.new_subnet_01.id}"
  vip_port_id = "${vkcs_networking_port.port_lb.id}"
  vip_network_id = "${vkcs_networking_network.new_network_01.id}"
}


## Создаем слушателя
# HTTP
resource "vkcs_lb_listener" "listener_http" {
  name = "listener_http"
  protocol = "HTTP"
  protocol_port = 80
  loadbalancer_id = "${vkcs_lb_loadbalancer.loadbalancer.id}"
}

# HTTPS
resource "vkcs_lb_listener" "listener_https" {
  name = "listener_https"
  protocol = "HTTPS"
  protocol_port = 443
  loadbalancer_id = "${vkcs_lb_loadbalancer.loadbalancer.id}"
}

## Создаем пул
# Пул для HTTP
resource "vkcs_lb_pool" "lb_pool_http" {
  name = "lb_pool_http"
  protocol = "HTTP"
  lb_method = "ROUND_ROBIN" #ROUND_ROBIN, LEAST_CONNECTIONS, SOURCE_IP, or SOURCE_IP_PORT.
  listener_id = "${vkcs_lb_listener.listener_http.id}"
}

# Пул для HTTPS
resource "vkcs_lb_pool" "lb_pool_https" {
  name = "lb_pool_https"
  protocol = "HTTPS"
  lb_method = "ROUND_ROBIN" #ROUND_ROBIN, LEAST_CONNECTIONS, SOURCE_IP, or SOURCE_IP_PORT.
  listener_id = "${vkcs_lb_listener.listener_https.id}"
}

### Инстансы балансировщика
## Первый инстанс
# HTTP
resource "vkcs_lb_member" "lb_vm_web_01_http" {
  address = "10.10.10.100"
  protocol_port = 80 #Порт, на котором слушает приложение на вм
  pool_id = "${vkcs_lb_pool.lb_pool_http.id}"
  subnet_id = "${vkcs_networking_subnet.new_subnet_01.id}"
  weight = 1 #Больше вес -- больше запросов уходит на этот хост
}

# HTTPS
resource "vkcs_lb_member" "lb_vm_web_01_https" {
  address = "10.10.10.100"
  protocol_port = 443 #Порт, на котором слушает приложение на вм
  pool_id = "${vkcs_lb_pool.lb_pool_https.id}"
  subnet_id = "${vkcs_networking_subnet.new_subnet_01.id}"
  weight = 1 #Больше вес -- больше запросов уходит на этот хост
}

## Второй инстанс
# HTTP
resource "vkcs_lb_member" "lb_vm_web_02_http" {
  address = "10.10.10.150"
  protocol_port = 80
  pool_id = "${vkcs_lb_pool.lb_pool_http.id}"
  subnet_id = "${vkcs_networking_subnet.new_subnet_01.id}"
  weight = 2 #Больше вес -- больше запросов уходит на этот хост
}

# HTTPS
resource "vkcs_lb_member" "lb_vm_web_02_https" {
  address = "10.10.10.150"
  protocol_port = 443 #Порт, на котором слушает приложение на вм
  pool_id = "${vkcs_lb_pool.lb_pool_https.id}"
  subnet_id = "${vkcs_networking_subnet.new_subnet_01.id}"
  weight = 1 #Больше вес -- больше запросов уходит на этот хост
}

## Информация о балансировщике
output "loadbalancer_ip" {
  value = vkcs_networking_floatingip.ext_ip_lb.address
}
