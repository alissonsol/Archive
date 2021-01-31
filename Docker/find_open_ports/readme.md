# Find Open Ports

This document literally "documents" how I went from an idea to the implementation of a web page that finds open ports ports in a visitor's machine, assuming connectivity. My plan included dividing and conquering the problem into the following parts, which are the sections of the document:

- Solution to display a visitor's local IP address
- Solution to scan ports given IP address (assumes connectivity)
- Solution to scan ports for IP address of the page visitor
- Final considerations

There is an additional section with references to tools used and articles I read in the process of composing this solution (mainly those not already cited inline).

Alisson Sol (Feb/2018)

## Solution to display a visitor's local IP address

There are several solutions that display a visitor's IP address. However, for those behind a NAT, it will usually display the proxy address (and even in a local setting, that is a problem, since some machines may not be properly configured to avoid using the proxy for the local network). A solution that really displays the local internal IP address is available [here](https://github.com/beefproject/beef/wiki/Module:-Get-Internal-IP-WebRTC), and can be tested online at: http://net.ipcalf.com/. It requires specific browsers and versions (Firefox > 28 or Chrome).

After copying the code from [here](https://github.com/beefproject/beef/wiki/Module:-Get-Internal-IP-WebRTC) to a file **index.html**, create a **Dockerfile**, with the content:
```
FROM nginx
COPY index.html /usr/share/nginx/html/index.html
```

Then, build the image with the commands below (first removing any previous one with same name):
```
docker rmi -f find_open_ports
docker build -f Dockerfile -t find_open_ports .
```
Don't forget that final period. Save this command sequence, which will be reused later through this document to rebuild the image, after each update of the **Dockerfile**. It is annoying that the final image name can only use lowercase characters. Ces't la vie...

You should now have the image **find_open_ports** locally. Check with:
```
docker images
```

Let's run the image, in port 8888 (or another your prefer), and check if it displays the visitor's local IP address. Save this command sequence also, since it will be reused whenever needing to again run the container. Notice that the running instance is given a name, and so I include also the command to remove previous instances with the same name:
```
docker rm find_open_ports
docker run -it -p 8888:80 --name find_open_ports find_open_ports
```

Visit http://localhost:8888/ and check the progress so far. You should see a page similar to:

```
Your network IP is:
##.##.##.##
Make the locals proud. 
```

For now, stop that running container:
```
docker stop find_open_ports
```

Check it is no longer running with:
```
docker ps
```

Done with the this step!

## Solution to scan ports given IP address (assumes connectivity)

The next challenge is, given an IP address that the server machine can establish a connection to, scan for open ports. Luckily, that can be done with NMap, and there are Docker images created for it, like [this one](https://hub.docker.com/r/infoslack/nmap/). That project has a simple [Dockerfile](https://hub.docker.com/r/infoslack/nmap/~/dockerfile/) used to create the NMap container image. Basically, it installs NMap, and then defines that executable as the container [entrypoint](https://docs.docker.com/engine/reference/builder/#entrypoint).

Adapting from that knowledge, the **Dockerfile** can be updated to:
```
FROM nginx
COPY index.html /usr/share/nginx/html/index.html
RUN apt-get update && apt-get -y install nmap
```
Afterwards, rebuild the image (as per previous Docker command sequence).

Starting this image (see command sequence previously defined), one should be able to use NMap from the shell. While that instance is running, one can also connect to http://localhost:8888 and get the visitor's IP address. Remember to stop the instance before proceeding.

## Solution to scan ports for IP address of the page visitor

Connecting two smaller solutions into a larger one for the end-to-end scenario requires finding a way to invoke the shell command from the web page, having as a parameter the client machine IP address (local, and assumed accessible from the server).

There are several intermediate problems and solutions in that road. Searching for support to the "Common Gateway Interface" [CGI](https://en.wikipedia.org/wiki/Common_Gateway_Interface), I could find that Nginx supports even [FastCGI](https://en.wikipedia.org/wiki/FastCGI). Install instructions are available  [here](https://www.linode.com/docs/web-servers/nginx/install-and-configure-nginx-and-php-fastcgi-on-ubuntu-16-04/).

Before proceeding, I just need to document that, as always, there are other options: 
- Have some Javascript sent to the client-side, which scan ports locally. An example of such kind of code can be found at [JS-Recon](http://www.andlabs.org/tools/jsrecon.html). Since that one only worked in Windows, I didn't investigate further, focusing on some other cross-platform approach.
- Compose a Docker application with both images (site and scanner). When the container with the web page is visited, it somehow runs the container with NMap installed, passing the visitor's address as a parameter and displaying its output. I did some research of technologies like [Dockerode](https://github.com/apocas/dockerode), but that looked too complex for the problem at hand.

My solution was just to start with a Docker image of Ubuntu, install Nginx and NMap, along with whatever is needed for invoking NMap from the web page. Then 'configure' everything as needed. The final [Dockerfile](Dockerfile) becomes:
```
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
```

That looks like a lot instructions. Yet, other than the many install steps, the key is to understand the content added to the image, and what it does.

The first file added is the home page [index.html](index.html).
```
COPY index.html /var/www/html/index.html
```
That is exactly the same page previously used (literally copied from [here](https://github.com/beefproject/beef/wiki/Module:-Get-Internal-IP-WebRTC)), with a minor function added to call the scan_address CGI script that invokes NMap.

Next, the [scan_address.cgi](scan_address.cgi) file is copied into the **cgi-bin** folder:
```
COPY scan_address.cgi /usr/lib/cgi-bin/scan_address.cgi
```
This is simply a Bash script that executes NMap, returning its output as Html content.

The **default file** configuration for the Nginx file needs some modifications to add the **cgi-bin** location. A modified [default](default) file replaces the original one:
```
COPY default /etc/nginx/sites-available/default
```
This is likely what can demand further maintenance in the future. Ideally, what would be done would be just inserting the block **location /cgi-bin/** into the **default** file. Something to investigate later.

Finally, a startup script - [startup.sh](startup.sh) - is added to run several services at once as the container starts. Only one [CMD](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#cmd) per **Dockerfile** is executed, and so this is one more of those 'hacks' that overcome limitations of tools:
```
COPY startup.sh /startup.sh
```

Start the container instance (see command sequence previously defined), and navigate to the server name using the port you used to expose the internal port 80 from the container (port 8888 in the previous startup command). Navigating to that machine at the mapped port (locally, http://localhost:8888) should now start a scanning process for the client machine (assuming local connectivity to the server, since NMap is executed with the local NAT address).

## Final considerations

The NMap execution may take a while, depending on the network conditions. Due to that, a counter is added to the Javascript function in **index.html** to show the web page is still 'alive'.

Some other issues that should be documented for the future are:
- At times, I got some strange problems that, after a little investigation, resulted from the infamous CR/LF versus LF end-of-line character conversion between Linux and Windows (since I did most of my editing in Windows). In the end, I resolved that by using [Notepad++](https://notepad-plus-plus.org/) as my file editor in Windows.
- The final page had to be exposed in the machine port 80. Again, due to developing in Windows, I had some collisions when testing that. It looks like all services in Windows somehow want to also listen to port 80 (try **netstat -nao | find ":80"**). The **http.sys** is particularly annoying, and i had to follow guidance [here](https://www.mikeplate.com/2011/11/06/stop-http-sys-from-listening-on-port-80-in-windows/) to address its interference.


Because of my Windows preference, I uncovered two issues only when finally building and deploying the container in a Linux machine:
- First was the fact that **apt-get** was failing when building the container in Ubuntu, despite everything working in Windows. The solution was found reading the article "[apt-get does not work inside Container when running Docker on a Ubuntu VM](https://github.com/moby/moby/issues/7138)". The key is commenting that line **dns=dnsmasq** in the **NetworkManager.conf** file. I also followed the steps in the article "[apt-get update fails to fetch files, “Temporary failure resolving …” error](https://askubuntu.com/questions/91543/apt-get-update-fails-to-fetch-files-temporary-failure-resolving-error)", although later I reverted that and things also worked.
- While the container in Windows had no problems executing the files not tagged as executable, I only added to **chmod** statements to the **Dockerfile** after building the image in Linux and seeing first the failure for the containter to run (failing **startup.sh**), and later the failure to execute the **scan_address.cgi**. In both cases, you get cryptic permission messages that one may not promptly related to the lack of **chmod** settings.

Besides that final setting of having the web page exposed in the default web port, it is also useful to have the container always restarting if some error happens. Containers can started with a defined "[restart policy](https://docs.docker.com/config/containers/start-containers-automatically/#restart-policy-details)". My final start command was (in Linux, demanding the **sudo**):
```
sudo docker run -it -p 80:80 --restart always --name find_open_ports find_open_ports
```

Last, but not least, let's talk about security. It is not like you couldn't have issues in the past, including in your code frameworks that could have bugs or malware. Yet, now you are able to quickly develop 'solutions' that will rely on entire images being downloaded from the Internet and configured for your specific application.

Container exploitation is only starting, and luckily solutions are also starting to appear. Docker itself is doing a good job by providing some security [guidance](https://www.docker.com/docker-security). Companies like [Aqua](https://www.aquasec.com/) are also providing solutions to scan your container images at build and runtime, alerting you of vulnerabilities. It is likely all major cloud platforms, from AWS to Azure, will also soon include some monitoring to alert you of deployment containing old or newly uncovered vulnerabilities.

No matter how many absurd explanations you are given: containers don't change anything regarding the need of having established processes to prevent and respond to the inevitable cybersecurity incidents that happen due to software vulnerabilities. If anything, you now have one more kind of artifact to keep track of: the provenance for all your container images. If you are not already following something similar, I recommend reading about the [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework).

## References

- Markdown Monster: https://markdownmonster.west-wind.com/download.aspx
- Docker Community Edition (CE): https://docs.docker.com/docker-for-windows/install/
- How To Containerize and Use Nginx as a Proxy: https://www.digitalocean.com/community/tutorials/docker-explained-how-to-containerize-and-use-nginx-as-a-proxy
- How to execute CGI scripts using fcgiwrap: https://blog.sleeplessbeastie.eu/2017/09/18/how-to-execute-cgi-scripts-using-fcgiwrap/
- The tool I use to connect to Macs and Linux from Windows is Remotix: https://www.nulana.com/remotix-windows/
