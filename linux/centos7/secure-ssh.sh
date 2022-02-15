#!/bin/bash
$name = $1

if [ -d "/home/$name/.ssh"]
then
    cd /home/$name
    https://github.com/ChampPG/test-repo/linux/public-keys
    cp ./home/$uname/linux/public-keys/id_rsa.pub /home/$name/.ssh/authorized_keys
    chmod 700 /home/$name/.ssh
    chmod 600 /home/$name/.ssh/authorized_keys
    chown $uname:$name /home/$name/.ssh
    echo "You're all set!"
else
    useradd -m -d /home/$name -s /bin/bash $name
    mkdir -p /home/$name/.ssh
    cd /home/$name
    git clone https://github.com/ChampPG/test-repo/tree/main/linux/public-keys
    cp ./home/$uname/linux/public-keys/id_rsa.pub /home/$name/.ssh/authorized_keys
    chmod 700 /home/$name/.ssh
    chmod 600 /home/$name/.ssh/authorized_keys
    chown $uname:$name /home/$name/.ssh
    sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
    /etc/init.d/ssh restart
    echo "you're all set"


#secure-ssh.sh
#author Paul
#creates a new ssh user using $1 parameter
#adds a public key from the local repo or culed from the remote repo
#removes roots ability to ssh in
