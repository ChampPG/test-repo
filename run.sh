#!/bin/bash

#arg 1 is IP Address of CA
#arg 2 is IP Web Server

echo 'WebServer client setup with CA ssh'

# install httpd tmux and tree
sudo yum install -y httpd tmux tree 

# httpd install and firewall
systemctl enable httpd
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload
sudo systemctl start httpd
sudo systemctl status httpd

# Set up website
cd /var/www/html
echo '<html>' >> index.html
echo '<head><title>Pauls Website</title></head>' >> index.html
echo '<body>' >> index.html
echo '<p>Hi Eastman! </p>' >> index.html
echo '</body>' >> index.html
echo '</html>' >> index.html
sudo hostnamectl set-hostname paul-webserver

openssl req -newkey rsa:2048 -keyout websrv.key -out websrv.csr
scp websrv.csr root@$1:/etc/pki/CA

echo "rebooting in 10"
sleep 10
reboot

#ssh CA
ssh root@$1

#prep Cert
cd /etc/pki/CA
touch index.txt
echo 1000 > serial

#gen CA key and pem
openssl genrsa -des3 -out private/cakey.pem 2048
openssl req -new -x509 -days 365 -key private/cakey.pem -out cacert.pem

#gen websrv.crt
openssl ca -out websrv.crt -infiles websrv.csr
scp websrv.crt paul@$2

#return to websrv
exit

#get key and cert copied
cd /home/paul
cp websrv.crt /etc/pki/tls/certs/websrv.crt
cp websrv.key /etc/pki/tls/private/websrv.key

#install mod_ssl for https
yum -y install mod_ssl

echo 'Now update /etc/httpd/conf.d/ssl.conf'
echo 'find SSLCertificateFile'
echo 'find SSLCertificateKeyFile'
echo 'then restart httpd from root'
sleep 10

#edit SSLCerticateFile and SSLCertificateKeyFile
vi /etc/httpd/conf.d/ssl.conf

