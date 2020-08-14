resource "virtualbox_vm" "node" {
    count     = 1
    name      = format("node-%02d", count.index + 1)
    image     = "https://app.vagrantup.com/ubuntu/boxes/bionic64/versions/20200812.0.0/providers/virtualbox.box"
    cpus      = 4
    memory    = "4096 mib"
    user_data = file("${module.path}/user_data")

    network_adapter {
       type = "bridged"
       host_interface="en0"
    }
}

output "IPAddr" {
  value = element(virtualbox_vm.node.*.network_adapter.0.ipv4_address, 1)
}