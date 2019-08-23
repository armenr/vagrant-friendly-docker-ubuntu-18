# vagrant-friendly-docker-ubuntu-18
A vagrant-friendly Ubuntu 18.04 Docker build (this will upset the Docker blowhards - we violate Docker conventions on purpose)

## Rationale
We don't want to use Docker in production, but we *do* like how much faster it is than VirtualBox and fully-virtualized environments.

We wanted to use Docker instead of VirtualBox for our Vagrant workflow, along with Ansible. So, we did a thing.

## What's in the box?
It's actually pretty simple.

This image installs python and ssh-server.

Things we do:

- Insert Vagrant's default insecure key for the vagrant user

- Set up reasonable SSH services and configurations

- Use SystemD hack to expose SystemD upwards to Vagrant and the running Ansible system such that you can query running system services through Ansible's systemd/service modules

## How do I use it?
