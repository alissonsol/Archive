FROM ubuntu

# System update and making it ready to install other pieces
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get -y install apt-utils
RUN apt-get -y install deborphan
RUN apt-get upgrade -y
RUN apt-get dist-upgrade -y
RUN deborphan | xargs apt-get -y remove --purge
RUN deborphan --guess-data | xargs apt-get -y remove --purge

# Install Nginx, cgiwrap and PHP
RUN apt-get install -y nano wget dialog net-tools
RUN apt-get install -y nginx    
RUN apt-get install -y fcgiwrap
RUN apt-get install -y php

# Install NMap
RUN apt-get -y install nmap

# Add content
COPY index.html /var/www/html/index.html
COPY scan_address.cgi /usr/lib/cgi-bin/scan_address.cgi
COPY default /etc/nginx/sites-available/default
COPY startup.sh /startup.sh
RUN ["chmod", "+x", "/usr/lib/cgi-bin/scan_address.cgi"]
RUN ["chmod", "+x", "/startup.sh"]

# Final service cleanup and starting command
RUN apt-get autoclean -y
EXPOSE 80
CMD /startup.sh