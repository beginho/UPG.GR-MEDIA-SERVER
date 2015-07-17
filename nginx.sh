#!/bin/bash
sudo apt-get update -y
sudo apt-get install build-essential nmap libpcre3 git libpcre3-dev libssl-dev unzip software-properties-common php5-common php5-cli php5-fpm lynx nmap -y
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
iptables -I INPUT -p tcp --dport 1935 -j ACCEPT
mkdir /var/log/nginx/
touch /var/log/nginx/error.log
cd /etc/php5/cli
sudo mv php.ini php.ini.backup
sudo ln -s ../fpm/php.ini
sudo service php5-fpm start
sudo mkdir ~/working
cd ~/working
git clone git://github.com/upggr/nginx.git
git clone git://github.com/upggr/nginx-rtmp-module.git
git clone git://github.com/upggr/UPG.GR-MEDIA-SERVER.git
cp ~/working/UPG.GR-MEDIA-SERVER/conf/nginx.txt /etc/init.d/nginx
sudo chmod +x /etc/init.d/nginx
sudo /usr/sbin/update-rc.d -f nginx defaults
cd ~/working/nginx
sudo chmod +x configure
./configure --with-http_ssl_module --add-module=../nginx-rtmp-module
sudo make && make install
mkdir /usr/local/nginx/html/hls/
mkdir /usr/local/nginx/html/dash/
mkdir /usr/local/nginx/html/dash/tmp/
mkdir /usr/local/nginx/html/hls/tmp/
touch /etc/nginx/nginx.conf
touch /usr/local/nginx/conf/nginx.conf
cp ~/working/UPG.GR-MEDIA-SERVER/conf/nginx.conf /usr/local/nginx/conf/nginx.conf
ip=$(ifconfig eth0 | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}')
cp -a ~/working/UPG.GR-MEDIA-SERVER/www/. /usr/local/nginx/html
sed -i -- 's/replaceip/'"$ip"'/g' /usr/local/nginx/conf/nginx.conf
sed -i -- 's/localhost/'"$ip"'/g' /usr/local/nginx/html/stream.xml
rm -f /usr/local/nginx/conf/nginx.conf.default
ln -s /usr/local/nginx/sbin/nginx nginx
sudo apt-get install ffmpeg -y
sudo service nginx start
sudo rm -rf ~/working
shutdown -r -t 10
