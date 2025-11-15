Vagrant.configure("2") do |config|
  # Use the same key for each machine
#  config.ssh.insert.key = false

#  config.vm.provider "virtualbox"
  config.vm.box = "generic/centos9s"
  config.vm.box_version = "4.3.12"
  config.vm.synced_folder ".", "/vagrant"
  config.vm.define "control" do |control|
    control.vm.network "private_network", ip: "192.168.10.10", hostname: true
    control.vm.hostname = "control"
    control.vm.provider "libvirt" do |kvm|
      kvm.memory = 2048
      kvm.cpus = 2
    end
    control.vm.provision "shell", path: "provisioner/control.sh"
  end

  config.vm.define "vagrant1" do |vagrant1|
    vagrant1.vm.network "private_network", ip: "192.168.10.20", hostname: true
    vagrant1.vm.provider "libvirt" do |kvm|
      kvm.memory = 1024
      kvm.cpus = 1
    end
    vagrant1.vm.provision "shell", path: "provisioner/vagrant1.sh"
  end

  config.vm.define "vagrant2" do |vagrant2|
    vagrant2.vm.network "private_network", ip: "192.168.10.30", hostname: true
    vagrant2.vm.provider "libvirt" do |kvm|
      kvm.memory = 1024
      kvm.cpus = 1
    end
    vagrant2.vm.provision "shell", path: "provisioner/vagrant2.sh"
  end
end    
