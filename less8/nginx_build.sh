#!/bin/bash
#Otus-linux hometask
#BUILD RPM nginx script
#packages for build
    sudo yum install -y redhat-lsb-core rpmdevtools yum-utils wget createrepo
#make folders tree
    sudo rpmdev-setuptree
#get nginx and ldap modelu sources
    cd /root/rpmbuild
    wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm
    sudo git clone https://github.com/kvspb/nginx-auth-ldap.git /root/nginx-auth-ldap
#unpack 
    rpm -ivh nginx-*
#builddep
    sudo yum-builddep -y nginx-1.14.1-1.el7_4.ngx.src.rpm
#build from spec
    sudo rm -f /root/rpmbuild/SPECS/nginx.spec
    sudo cp /home/vagrant/otus_linux/less8/nginx.spec /root/rpmbuild/SPECS/
    sudo cp /home/vagrant/otus_linux/less8/nginx.spec /root/rpmbuild/
    sudo cd /root/rpmbuild/SPECS/ && sudo rpmbuild -ba nginx.spec
#install
    sudo yum localinstall -y /root/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
    sudo rm -f /etc/nginx/conf.d/default.conf
    sudo cp /home/vagrant/otus_linux/less8/default.conf /etc/nginx/conf.d/
    sudo systemctl start nginx
    sudo nginx -t
    sudo nginx -s reload
#create repo
    mkdir /usr/share/nginx/html/repo
    sudo cp /root/rpmbuild/RPMS/x86_64/nginx-1.* /usr/share/nginx/html/repo
    sudo createrepo /usr/share/nginx/html/repo/
#edit repos.d
    sudo cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=less8_kdv
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
    EOF
#yum repolist enabled | grep kdv
#yum list | grep kdv