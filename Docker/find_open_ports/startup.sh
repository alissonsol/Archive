#!/bin/bash
# Script to start multple services

startc() {
    echo "Services for container are being started..."
    /etc/init.d/php7.0-fpm restart >> /var/log/startup.log
    /etc/init.d/fcgiwrap restart >> /var/log/startup.log
    /etc/init.d/nginx restart >> /var/log/startup.log
    echo "The container services have started..."
}

stopc() {
    echo "Services for container are being stopped..."
    /etc/init.d/nginx stop >> /var/log/startup.log
    /etc/init.d/php7.0-fpm stop >> /var/log/startup.log
    /etc/init.d/fcgiwrap stop >> /var/log/startup.log
    echo "Services for container have successfully stopped. Exiting."
}

trap "(stopc)" TERM

# Startup
startc

# Pause script to keep container running...
stop="no"
while [ "$stop" == "no" ]
do
echo "Type [stop] or run 'docker stop ${CNAME}' from host."
read input
if [ "$input" == "stop" ]; then stop="yes"; fi
done

# Stop init.d services upon exiting loop
stopc
