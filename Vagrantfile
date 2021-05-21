# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "hashicorp/bionic64"

  config.vm.network :forwarded_port, guest: 5432, host: 5433

  if Vagrant::Util::Platform.windows?
    config.vm.synced_folder "./", "/vagrant", type: "smb"
  else
    config.vm.synced_folder "./", "/vagrant"
  end

  config.vm.provider :vmware_esxi do |esxi|
    esxi.guest_name = 'Node-Postgres-Vagrant'
    esxi.esxi_hostname = 'HOSTNAME/IP';
    esxi.esxi_username = 'USERNAME';
    esxi.esxi_password = 'prompt:'
    
    esxi.guest_numvcpus = '2'
    esxi.guest_memsize = '2048'
    esxi.guest_boot_disk_size = 100
    esxi.guest_disk_type = 'thin'
    esxi.esxi_virtual_network = ['VM Network']
    esxi.guest_guestos = 'ubuntu-64'
  end

  config.vm.provision "shell", path: "bootstrap.sh", privileged: true

  config.vm.provision "shell", run: "always", inline: <<-SHELL
    pm2 restart 0
  SHELL
end
