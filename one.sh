#!/bin/bash

echo 'WebServer client setup with CA ssh'

if [ $1 = 1 ]
then
  adduser paul
  passwd paul
  usermod -aG wheel paul
  cp one.sh /home/paul
elif [ $1 = 2 ]
then
  scp /etc/pki/CA/websrv.crt paul@web:/home/paul/websrv.crt
elif [ $1 = 3 ]
  sudo su
  # Set up website
  cd /var/www/html
  sudo echo '<!DOCTYPE html>' >> index.html
  sudo echo '<html>' >> index.html
  sudo echo '<head><title>Pauls Website</title></head>' >> index.html
  sudo echo '<body>' >> index.html
  sudo echo '<p>Hi Eastman! </p>' >> index.html
  sudo echo '</body>' >> index.html
  sudo echo '</html>' >> index.html
  
  echo "now systemctl restart httpd"
  sudo systemctl restart httpd

  echo 'done!'
else
  echo 'enter CA IP'
  read caip

  echo 'enter web IP'
  read webip
  
  scp /home/paul/one.sh root@$caip:/root/one.sh

  # install httpd tmux and tree
  sudo yum install -y httpd tmux tree 

  # httpd install and firewall
  systemctl enable httpd
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
  scp websrv.csr root@$caip:/etc/pki/CA

  #ssh CA
  echo 'enter serial for CA'
  read num
  
  echo "number of days for cert"
  read days
  
  ssh root@$caip "echo "$webip web" > /etc/hosts ; cd /etc/pki/CA ; touch /etc/pki/CA/index.txt ; echo $num > /etc/pki/CA/serial ; openssl genrsa -des3 -out /etc/pki/CA/private/cakey.pem 2048 ; openssl req -new -x509 -days $days -key /etc/pki/CA/private/cakey.pem -out /etc/pki/CA/cacert.pem ; openssl ca -out /etc/pki/CA/websrv.crt -infiles /etc/pki/CA/websrv.csr"

  echo '/etc/pki/tls/certs/websrv.crt'
  echo 
  echo 'scp /etc/pki/CA/websrv.crt paul@web:/home/paul/websrv.crt'
  echo 'chmod +x one.sh'
  echo 'run ./one.sh 2 and then hit enter'
  read yes
 
  #get key and cert copied
  cd /home/paul
  sudo cp websrv.crt /etc/pki/tls/certs/websrv.crt
  sudo cp websrv.key /etc/pki/tls/private/websrv.key

  #install mod_ssl for https
  sudo yum -y install mod_ssl

  echo 'Now update /etc/httpd/conf.d/ssl.conf'
  echo 'find SSLCertificateFile'
  echo 'find SSLCertificateKeyFile'
  echo 'then ./one.sh 3'
  sleep 5
  
  #edit SSLCerticateFile and SSLCertificateKeyFile
  sudo vi /etc/httpd/conf.d/ssl.conf
fi
