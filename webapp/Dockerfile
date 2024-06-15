FROM ubuntu:jammy-20240530
LABEL "AUTHOR" = "Johith Iype"
LABEL "PROJECT" = "johith.com"

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install apache2=2.4.52-1ubuntu4.9 -y
cmd ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
EXPOSE 80
WORKDIR /var/www/html
COPY ./2106_soft_landing/ ./
