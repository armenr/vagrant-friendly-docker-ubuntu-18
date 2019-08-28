# vagrant-friendly-docker-ubuntu-18

A vagrant-friendly Ubuntu 18.04 Docker build (this will upset the Docker blowhards - we violate Docker conventions on purpose)

## Rationale

We don't want to use Docker in production, but we *do* like how much faster it is than VirtualBox and fully-virtualized environments.

We wanted to use Docker instead of VirtualBox for our Vagrant workflow, along with Ansible. So, we did a thing.

## What's in the box

It's actually pretty simple.

This image installs python and ssh-server.

Things we do:

- Insert Vagrant's default insecure key for the vagrant user

- Set up reasonable SSH services and configurations

- Use SystemD hack to expose SystemD upwards to Vagrant and the running Ansible system such that you can query running system services through Ansible's systemd/service modules

## How do I use it

See our example Vagrantfile

```ruby

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'docker'

Vagrant.configure("2") do |config|

## Configure Docker provider for all vms
    config.vm.provider "docker" do |d|
        # d.build_dir       = "./"
        # d.git_repo =
        d.image                     = 'armenr/ubuntu18.04-vagrant'
        d.pull                      = true
        d.has_ssh                   = true
        d.remains_running           = true
        # Use these implicit port mappings at your own risk for multi-machine
        # d.ports = [ "5044:5044" ]
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
          d.link "machine2:machine2"
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

```
