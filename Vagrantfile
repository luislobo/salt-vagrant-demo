# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  os = "bento/ubuntu-18.04"
  net_ip = "192.168.50"
  
  # force creation of NATSwitch
  config.trigger.before :up do |trigger|
    trigger.info = "Creating 'NATSwitch' Hyper-V switch if it does not exist..."
    trigger.run = {privileged: "true", powershell_elevated_interactive: "true", path: "./scripts/create-nat-hyperv-switch.ps1"}
  end
  
  config.vm.provider "hyperv"
  config.vm.synced_folder ".", "/vagrant", type: "rsync"
  
  config.vm.provider "hyperv" do |h|
    h.enable_virtualization_extensions = true
    h.linked_clone = true
  end

  config.vm.define :master, primary: true do |master_config|

    master_config.vm.provider "hyperv" do |h|
      h.memory = "2048"
      h.cpus = 1
      h.enable_virtualization_extensions = true
      h.linked_clone = true
      h.vmname = "master"
    end

    # Reconfigure Hyper-V on before reload to the NATSwitch
    master_config.trigger.before :reload do |trigger|
      trigger.info = "Setting master Hyper-V switch to 'NATSwitch' to allow for static IP..."
      trigger.run = {privileged: "true", powershell_elevated_interactive: "true", path: "./scripts/set-hyperv-switch.ps1", args: 'master' }
    end
    
    master_config.vm.box = "#{os}"
    master_config.vm.host_name = 'saltmaster.local'
    master_config.vm.provision "shell", path: "./scripts/configure-static-ip.sh", args: "#{net_ip}.10"
    master_config.vm.provision :reload
    
    master_config.vm.synced_folder "saltstack/salt/", "/srv/salt", type: "rsync"
    master_config.vm.synced_folder "saltstack/pillar/", "/srv/pillar", type: "rsync"

    master_config.vm.provision :salt do |salt|
      salt.master_config = "saltstack/etc/master"
      salt.master_key = "saltstack/keys/master_minion.pem"
      salt.master_pub = "saltstack/keys/master_minion.pub"
      salt.minion_key = "saltstack/keys/master_minion.pem"
      salt.minion_pub = "saltstack/keys/master_minion.pub"
      salt.seed_master = {
                          "minion1" => "saltstack/keys/minion1.pub",
                          "minion2" => "saltstack/keys/minion2.pub"
                         }

      salt.install_type = "stable"
      salt.install_master = true
      salt.no_minion = true
      salt.verbose = true
      salt.colorize = true
      salt.bootstrap_options = "-P -c /tmp"
    end
  end


  [
    ["minion1",    "#{net_ip}.11",    "1024",    os ],
    ["minion2",    "#{net_ip}.12",    "1024",    os ],
  ].each do |vmname,ip,mem,os|
    config.vm.define "#{vmname}" do |minion_config|

      # Configure Vagrant Reload Trigger
      minion_config.trigger.before :reload do |trigger|
        trigger.info = "Setting #{vmname} Hyper-V switch to 'NATSwitch' to allow for static IP..."
        trigger.run = {privileged: "true", powershell_elevated_interactive: "true", path: "./scripts/set-hyperv-switch.ps1", args: "#{vmname}" }
      end
    
      minion_config.vm.provider "hyperv" do |h|
        h.memory = "#{mem}"
        h.cpus = 1
        h.enable_virtualization_extensions = true
        h.linked_clone = true
        h.vmname = "#{vmname}"
      end

      minion_config.vm.box = "#{os}"
      minion_config.vm.hostname = "#{vmname}"
      minion_config.vm.provision "shell", path: "./scripts/configure-static-ip.sh", args: "#{ip}"
      minion_config.vm.provision :reload

      minion_config.vm.provision :salt do |salt|
        salt.minion_config = "saltstack/etc/#{vmname}"
        salt.minion_key = "saltstack/keys/#{vmname}.pem"
        salt.minion_pub = "saltstack/keys/#{vmname}.pub"
        salt.install_type = "stable"
        salt.verbose = true
        salt.colorize = true
        salt.bootstrap_options = "-P -c /tmp"
      end
    end
  end
end
