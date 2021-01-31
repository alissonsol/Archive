docker stop http_fileshare
docker rm http_fileshare
docker rmi -f http_fileshare
docker build -f Dockerfile -t http_fileshare .
docker volume create --name site-data
docker run -it -p 80:80 -p 137:137 -p 138:138 -p 139:139 -p 445:445 -v site-data:/mnt/site-data --name http_fileshare http_fileshare
# Below is the line for MacOS
# docker run -it -p 80:80 -p 127.0.0.2:137:137 -p 127.0.0.2:138:138 -p 127.0.0.2:139:139 -p 127.0.0.2:445:445  -v site-data:/mnt/site-data --name http_fileshare http_fileshare
