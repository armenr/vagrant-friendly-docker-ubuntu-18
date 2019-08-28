ENV['VAGRANT_DEFAULT_PROVIDER'] = 'docker'

Vagrant.configure("2") do |config|

## Configure Docker provider for all vms
    config.vm.provider "docker" do |d|
        # d.build_dir       = "./"
        # d.git_repo = "git@github.com:armenr/vagrant-friendly-docker-ubuntu-18.git"
        d.image                     = 'armenr/ubuntu18.04-vagrant'
        d.pull                      = true
        d.has_ssh                   = true
        d.remains_running           = true
        # d.ports = [ "5044:5044" ]     # Use these universal port mappings at your own risk in multi-machine setups
    end

    ## Using vanilla vagrant ssh settings & keys
    config.ssh.username   = 'vagrant'
    config.vm.network :private_network, type: "dhcp", docker_network__internal: true

    # NOTE - for later: https://github.com/devopsgroup-io/vagrant-hostmanager
    # config.hostmanager.enabled           = true
    # config.hostmanager.manage_guest      = true
    # config.vm.provision :hostmanager

## Begin defining vms

    ## Sample docker1
    config.vm.define :machine1 do |machine1|
        machine1.vm.hostname = "machine1"
        machine1.vm.provider "docker" do |d, override|
          d.name = "machine1"
          d.ports = [ "5044:5044" ]
          d.link "machine1:machine1"
        end
    end

    ## Sample docker2
    config.vm.define :machine2 do |machine2|
      machine2.vm.hostname = "machine2"
      machine2.vm.provider "docker" do |d, override|
        d.name = "machine2"
        d.ports = [ "5000:5000" ]
      end
    end

## End all vms
end
