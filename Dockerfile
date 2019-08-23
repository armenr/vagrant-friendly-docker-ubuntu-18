# Revisit build stages & overall thinking: https://github.com/dholth/vagrant-docker/blob/master/Dockerfile
FROM ubuntu:18.04
EXPOSE 22 2200

# Update image and install packages
RUN DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y aptitude python sudo openssh-server

# Add passwordless Vagrant user w/ passwordless sudoer privs
RUN adduser --disabled-password --gecos '' vagrant \
  && adduser vagrant sudo \
  && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/vagrant_user

# Inject Vagrant's standard insecure SSH key & set correct ownership
RUN cd ~vagrant \
  && mkdir .ssh \
  && echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" > .ssh/authorized_keys \
  && chown -R vagrant:vagrant .ssh \
  && chmod 0700 .ssh \
  && chmod 0600 .ssh/authorized_keys

# Do SSH things
RUN mkdir /var/run/sshd \
  && sed 's|^PermitRootLogin\s+.*|PermitRootLogin no|' -i /etc/ssh/sshd_config \
  && sed 's/UsePAM yes/#UsePAM yes/g' -i /etc/ssh/sshd_config \
  && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# These are here to add some SSH sanity and stability...YMMV
RUN sed -i '/^#.* TCPKeepAlive /s/^#//g' /etc/ssh/sshd_config
RUN sed -i '/^#.* ClientAliveInterval /s/^#//g' /etc/ssh/sshd_config
RUN sed -i '/^#.* ClientAliveCountMax /s/^#//g' /etc/ssh/sshd_config
RUN service ssh restart

# Wanna know why we did this? See link:
# https://stackoverflow.com/questions/36292317/why-set-visible-now-in-etc-profile
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Inspired by: https://github.com/ManageIQ/container-embedded-ansible/blob/master/Dockerfile
# Breadcrumb: https://forums.docker.com/t/systemctl-status-is-not-working-in-my-docker-container/9075/14
## This allows for Ansible's "service" & "systemd" modules to work out of the box
## Systemd cleanup base image
RUN (cd /lib/systemd/system/sysinit.target.wants && for i in *; do [ $i = systemd-tmpfiles-setup.service ] || rm -vf $i; done) && \
  rm -vf /lib/systemd/system/multi-user.target.wants/* && \
  rm -vf /etc/systemd/system/*.wants/* && \
  rm -vf /lib/systemd/system/local-fs.target.wants/* && \
  rm -vf /lib/systemd/system/sockets.target.wants/*udev* && \
  rm -vf /lib/systemd/system/sockets.target.wants/*initctl* && \
  rm -vf /lib/systemd/system/basic.target.wants/* && \
  rm -vf /lib/systemd/system/anaconda.target.wants/*

RUN apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## Thes are all the services we'd target or expose
EXPOSE 80 2000
EXPOSE 3000 3000
EXPOSE 4000 4000
EXPOSE 5000 5000
EXPOSE 7777 7777
EXPOSE 8080 8080


CMD ["/usr/sbin/sshd", "-D"]
