#!/bin/bash

#arg 1 is IP Address of CA
#arg 2 is IP Web Server

echo '0 setup base web'
echo '1 setup CA'
echo '2 finsh web'
echo '3 setup webpage'

read select

if [ $select = 0 ]
then
  echo 'WebServer client setup with CA ssh'

  scp run.sh root@$1:/root

  # install httpd tmux and tree
  sudo yum install -y httpd tmux tree 

  # httpd install and firewall
  systemctl enable httpd
  sudo firewall-cmd --permanent --add-port=80/tcp
  sudo firewall-cmd --permanent --add-port=443/tcp
  sudo firewall-cmd --reload
  sudo systemctl start httpd
  sudo systemctl status httpd
  
  # set hostname web
  echo 'Please enter desired hostname: '
  read host
  sudo hostnamectl set-hostname $host

  cd /home/paul
  openssl req -newkey rsa:2048 -keyout websrv.key -out websrv.csr
  scp websrv.csr root@$1:/etc/pki/CA

  #echo "rebooting in 10"
  #sleep 10
  #reboot

  #ssh CA
  ssh root@$1
fi

if [ $select = 1 ]
then
  #prep Cert
  cd /etc/pki/CA
  touch index.txt
  echo 1004 > serial

  #gen CA key and pem
  openssl genrsa -des3 -out private/cakey.pem 2048
  openssl req -new -x509 -days 365 -key private/cakey.pem -out cacert.pem

  #gen websrv.crt
  openssl ca -out websrv.crt -infiles websrv.csr
  scp websrv.crt paul@$2:
  exit
fi

if [ $select = 2 ]
then
  #get key and cert copied
  cd /home/paul
  sudo cp websrv.crt /etc/pki/tls/certs/websrv.crt
  sudo cp websrv.key /etc/pki/tls/private/websrv.key

  #install mod_ssl for https
  sudo yum -y install mod_ssl

  echo 'Now update /etc/httpd/conf.d/ssl.conf'
  echo 'find SSLCertificateFile'
  echo 'find SSLCertificateKeyFile'
  echo 'then restart httpd from root'
  sleep 10

  #edit SSLCerticateFile and SSLCertificateKeyFile
  sudo vi /etc/httpd/conf.d/ssl.conf
fi

if [ $select = 3 ]
then
  # Set up website
  cd /var/www/html
  sudo echo '<!DOCTYPE html>' >> index.html
  sudo echo '<html>' >> index.html
  sudo echo '<head><title>Pauls Website</title></head>' >> index.html
  sudo echo '<body>' >> index.html
  sudo echo '<p>Hi Eastman! </p>' >> index.html
  sudo echo '</body>' >> index.html
  sudo echo '</html>' >> index.html
fi

#    if 0 setup base web
#    if 1 setup CA
#    if 2 finsh web
#    if 3 setup webpage
