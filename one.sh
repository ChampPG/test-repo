#!/bin/bash

echo 'WebServer client setup with CA ssh'

echo 'enter CA IP'
read caip

echo 'enter web IP'
read webip

ssh root@$caip /bin/bash << EOF
  ssh root@$webip /bin/bash << EOF
    adduser paul
    passwd paul
    usermod -aG paul
    exit
  EOF
  exit
EOF

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
scp websrv.csr root@$1:/etc/pki/CA

#ssh CA
ssh root@$caip /bin/bash << EOF
  #prep Cert
  cd /etc/pki/CA
  touch index.txt
  
  #serial for CA
  echo 'enter serial for CA'
  read num
  echo $num > serial

  #gen CA key and pem
  openssl genrsa -des3 -out private/cakey.pem 2048
  
  echo "number of days for cert"
  
  read days
  
  openssl req -new -x509 -days $days -key private/cakey.pem -out cacert.pem

  #gen websrv.crt
  openssl ca -out websrv.crt -infiles websrv.csr
  
  
  scp websrv.crt paul@$webip:
  exit
EOF

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
sleep 5

#edit SSLCerticateFile and SSLCertificateKeyFile
sudo vi /etc/httpd/conf.d/ssl.conf

ssh root@$caip /bin/bash << EOF
  ssh root@$webip /bin/bash << EOF
    # Set up website
    cd /var/www/html
    sudo echo '<!DOCTYPE html>' >> index.html
    sudo echo '<html>' >> index.html
    sudo echo '<head><title>Pauls Website</title></head>' >> index.html
    sudo echo '<body>' >> index.html
    sudo echo '<p>Hi Eastman! </p>' >> index.html
    sudo echo '</body>' >> index.html
    sudo echo '</html>' >> index.html
    sudo systemctl restart httpd
 EOF
EOF
echo 'done!'
