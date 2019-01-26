#1/bin/bash

cp -v ./conf/nginx/rajshrimohanks.me.nginx.conf /etc/nginx/sites-available/
cp -v ./conf/nginx/dns.conf                     /etc/nginx/snippets/
cp -v ./conf/nginx/http-headers.conf            /etc/nginx/snippets/
cp -v ./conf/nginx/ssl.conf                     /etc/nginx/snippets/
cp -v ./conf/nginx/rajshrimohanks.me.ssl.conf   /etc/nginx/ssl/

nginx -t

systemctl restart nginx
