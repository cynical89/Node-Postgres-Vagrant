# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
VM_NAME = 'Node-Postgres'
HOSTNAME = 'dev.node.test'
CPUS = 2
RAM = 2048


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "hashicorp/bionic64"

  config.landrush.enabled = true
  config.landrush.tld = HOSTNAME
  config.landrush.guest_redirect_dns = false
  config.landrush.host_interface_excludes = [/lo[0-9]*/, /docker[0-9]+/, /veth[0-9]+/, /br-[0-9a-z]+/]

  config.vm.hostname = HOSTNAME

  if Vagrant::Util::Platform.windows?
    config.vm.synced_folder "./", "/vagrant", type: "smb"
  else
    config.vm.synced_folder "./", "/vagrant"
  end

  config.vm.define "esxi" do |vme|
    vme.vm.provider :vmware_esxi do |esxi|
      esxi.guest_name = VM_NAME
      esxi.esxi_hostname = '10.34.1.6';
      esxi.esxi_username = 'root';
      esxi.esxi_password = 'prompt:'
      
      esxi.guest_numvcpus = CPUS
      esxi.guest_memsize = RAM
      esxi.guest_boot_disk_size = 100
      esxi.guest_disk_type = 'thin'
      esxi.esxi_virtual_network = ['VM Network']
      esxi.guest_guestos = 'ubuntu-64'
    end
  end

  config.vm.define "vbox" do |vbox|
    vbox.vm.provider "virtualbox" do |v|
      v.name = VM_NAME
      v.customize ["setextradata", :id,
                   "VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant",
                   "1"]
      v.customize ["modifyvm", :id,
                   "--natdnshostresolver1", "on",
                   "--memory", RAM,
                   "--cpus", CPUS]
    end
  end

  config.vm.provision "shell", path: "bootstrap.sh", privileged: true

  config.vm.provision "shell", run: "always", inline: <<-SHELL
    pm2 restart 0
  SHELL
end
