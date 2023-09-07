# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/focal64"
    # config.vm.box = "ubuntu/jammy64"
    


    config.vm.box_check_update = false
    config.ssh.insert_key = false
    # insecure_private_key download from https://github.com/hashicorp/vagrant/blob/master/keys/vagrant
    config.ssh.private_key_path = "insecure_private_key"

    c_machines = {
        'z1'   => '192.168.28.21',
        'z2'   => '192.168.28.22',
        'z3'   => '192.168.28.23',
        'z4'   => '192.168.28.24',
    }

    c_machines.each do |name, ip|
        config.vm.define name do |machine|
            machine.vm.network "private_network", ip: ip
            machine.vm.hostname = name
            machine.vm.provider :virtualbox do |vb|
                #vb.name = name
                vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
                vb.customize ["modifyvm", :id, "--vram", "32"]
                vb.customize ["modifyvm", :id, "--ioapic", "on"]
                vb.customize ["modifyvm", :id, "--cpus", "2"]
                vb.customize ["modifyvm", :id, "--memory", "3072"]
            end


            machine.vm.provision "shell", inline: <<-SHELL
            echo "root:vagrant" | sudo chpasswd
            bash /vagrant/init-os.sh

            curl -fsSL https://ghproxy.com/https://github.com/dyrnq/install-docker/raw/main/install-docker.sh | bash -s docker \
            --mirror tencent \
            --version 20.10.23 \
            --systemd-mirror ghproxy && \
            usermod -aG docker vagrant
            docker ps
            
            SHELL
        end
    end

end