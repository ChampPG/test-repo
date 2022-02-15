#!/bin/bash

echo "user $1"

if [ -d "/home/$1/.ssh" ]
then
    echo "Dir is there"
    cd /home/$1
    git clone https://github.com/ChampPG/test-repo/linux/public-keys
    cp ./home/$1/linux/public-keys/id_rsa.pub /home/$1/.ssh/authorized_keys
    chmod 700 /home/$1/.ssh
    chmod 600 /home/$1/.ssh/authorized_keys
    chown $1:$1 /home/$1/.ssh
    echo "You're all set!"
else
    echo "Dir isn't there"
    useradd -m -d /home/$1 -s /bin/bash $1
    mkdir -p /home/$1/.ssh
    cd /home/$1
    git clone https://github.com/ChampPG/test-repo/tree/main/linux/public-keys
    cp /home/$1/linux/public-keys/id_rsa.pub /home/$1/.ssh/authorized_keys
    chmod 700 /home/$1/.ssh
    chmod 600 /home/$1/.ssh/authorized_keys
    chown $1:$1 /home/$1/.ssh
    sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
    /etc/init.d/ssh restart
    echo "you're all set"
fi

#secure-ssh.sh
#author Paul
#creates a new ssh user using $1 parameter
#adds a public key from the local repo or culed from the remote repo
#removes roots ability to ssh in
