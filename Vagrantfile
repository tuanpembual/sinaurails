# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/xenial64"
  #config.vm.box = "debian/jessie64"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
    #vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end

  config.vm.define :sinaurails do |sinaurails|
    sinaurails.vm.host_name="sinaurails"
    sinaurails.vm.network "private_network", ip: "192.168.33.22"
    sinaurails.vm.network "forwarded_port", guest: 3000, host: 3000
    sinaurails.vm.provision "shell", inline: <<-SHELL
      sudo apt update
      sudo apt-get install -y curl gnupg build-essential libpq-dev postgresql postgresql-contrib nodejs && sudo ln -sf /usr/bin/nodejs /usr/local/bin/node
      sudo gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
      curl -sSL https://get.rvm.io | sudo bash -s stable
      sudo usermod -a -G rvm ubuntu
      if sudo grep -q secure_path /etc/sudoers; then sudo sh -c "echo export rvmsudo_secure_path=1 >> /etc/profile.d/rvm_secure_path.sh" && echo Environment variable installed; fi
      source /etc/profile.d/rvm.sh
      sudo chown -R ubuntu:ubuntu /usr/local/rvm
      rvm install ruby-2.3.3
      gem install bundler --no-rdoc --no-ri
    SHELL
  end

  # config.vm.define :production do |production|
  #   production.vm.host_name="production"
  #   production.vm.network "public_network", ip: "192.168.1.81"
  # end
end
