#!/bin/bash

#secure-ssh.sh
#author Paul
#creates a new ssh user using $1 parameter
#adds a public key from the local repo or culed from the remote repo
#removes roots ability to ssh in

$uname=$test1
$DIR=$/home/$uname
if [-d "$DIR"]
then
    ssh $uname@docker01-paul
else
    useradd -m -d /home/$uname -s /bin/bash $uname
    mkdir /home/$uname/.ssh
    cd /home/$uname
    git clone https://github.com/ChampPG/test-repo/linux/public-keys
    cp ./test-repo/id_rsa.pub /home/$uname/.ssh/authorized_keys
    chmod 700 /home/$uname/.ssh
    chmod 600 /home/$uname/.ssh/authorized_keys
    chown $uname:$uname /home/$uname/.ssh
    sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
    /etc/init.d/ssh restart
    ssh $uname@docker01-paul
