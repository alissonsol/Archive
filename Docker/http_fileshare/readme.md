# HTTP file share

Documents creation of container image to host multiple site across sessions with one being modifiable via file share.

There is an additional section with references to tools used and articles I read in the process of composing this solution (mainly those not already cited inline).

Alisson Sol (Oct/2018)

## Persistent volume

Needs to be created just once.
```
docker volume create --name site-data
```
Depending on your environment, you may need to be an administrator, or super user, prefixing docker commands with operating systems commands like 'su' or 'sudo'.

## Building basic image

Then, build the image with the commands below (first removing any previous one with same name):
```
docker rmi -f http_fileshare
docker build -f Dockerfile -t http_fileshare .
```
Don't forget that final period. Save this command sequence, which will be reused later through this document to rebuild the image, after each update of the **Dockerfile**. In some machines, you may need to build with the --no-cache option:
```
docker build --no-cache -f Dockerfile -t http_fileshare .
```

You should now have the image **http_fileshare** locally. Check with:
```
docker images
```

## Configuration

Let's run the image:
```
docker rm http_fileshare
docker run -it -p 80:80 -p 137-139:137-139 -p 445:445 -v site-data:/mnt/site-data --name http_fileshare http_fileshare
```

Visit http://localhost/ and check the progress so far.

Attach to the running image with the command:
```
docker exec -it http_fileshare /bin/bash
```

### The fileshare

Add the following to the end of the /etc/samba/smb.conf

```
[http_fileshare]
comment = HTTP fileshare
path = /mnt/site-data/http_fileshare
browseable = yes
read only = no
guest ok = yes
create mask = 0700
force user = www-data
force group = www-data
```

Set a Samba password for the www-data user
```
smbpasswd -a www-data
```

Create and change ownership of the shared folder
```
mkdir /mnt/site-data/http_fileshare
chown www-data:www-data /mnt/site-data/http_fileshare
```

Then, restart the Samba file share service (at times, it will be smbd, instead of samba)
```
service samba restart
```

Now, you should be able to connect to:
```
smb://www-data@localhost/http_fileshare
```

### Configuration persistence

It may be useful to save your configuration files to the /mnt/site-data location, restoring later.
For example, I mixed in a single container this http_fileshare and the service to find open ports in a visitor, from:
https://github.com/alissonsol/Docker/tree/master/find_open_ports

After both were configured, I had a script had to reconfigure the basic container, if needed:
```
apt-get -y install nmap
mkdir /usr/lib/cgi-bin/
cp /mnt/site-data/find_open_ports/cgi-bin/scan_address.cgi /usr/lib/cgi-bin/scan_address.cgi
chmod +x /usr/lib/cgi-bin/scan_address.cgi

cp /mnt/site-data/nginx/default /etc/nginx/sites-available/default
service nginx restart
cp /mnt/site-data/samba/smb.conf /etc/samba/smb.conf
service samba restart
```

### Troubleshooting

You may face port collision with services in the host machine when starting your container.
For example, if you have a SMB service running in the host, you may need to stop and disable it, with commands like:
```
sudo systemctl stop smbd; sudo systemctl disable smbd; sudo systemctl mask smbd;
sudo systemctl stop nmbd; sudo systemctl disable nmbd; sudo systemctl mask nmbd;
```

In a MacOS system, you may need to work around a limitation to connect to the local SMB server exposed from a container:
https://apple.stackexchange.com/questions/98331/can-i-connect-to-a-local-smb-share

## References

- Markdown Monster: https://markdownmonster.west-wind.com/download.aspx
- Docker Community Edition (CE): https://docs.docker.com/docker-for-windows/install/
- How To Containerize and Use Nginx as a Proxy: https://www.digitalocean.com/community/tutorials/docker-explained-how-to-containerize-and-use-nginx-as-a-proxy
- How to execute CGI scripts using fcgiwrap: https://blog.sleeplessbeastie.eu/2017/09/18/how-to-execute-cgi-scripts-using-fcgiwrap/
- The tool I use to connect to Macs and Linux from Windows is Remotix: https://www.nulana.com/remotix-windows/
- MacOS connection to localhost: https://github.com/dperson/samba/issues/84
