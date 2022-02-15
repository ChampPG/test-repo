#!/bin/bash
$name = $1
ssh-keygen -t rsa -C "$name" -f $name.pub
scp /home/$USER/.ssh/id_rsa.pub sys265@docker01-paul:

ssh sys265@docker01-paul

if [ -d "/home/$name/.ssh"]
then
    exit
    ssh $name@docker01-paul
else
    useradd -m -d /home/$name -s /bin/bash $name
    mkdir /home/$name/.ssh
    cd /home/$name
    cp ./home/sys265/id_rsa.pub /home/$name/.ssh/authorized_keys
    chmod 700 /home/$name/.ssh
    chmod 600 /home/$name/.ssh/authorized_keys
    chown $uname:$name /home/$name/.ssh
    sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
    /etc/init.d/ssh restart
    exit
    ssh $name@docker01-paul


#secure-ssh.sh
#author Paul
#creates a new ssh user using $1 parameter
#adds a public key from the local repo or culed from the remote repo
#removes roots ability to ssh in
