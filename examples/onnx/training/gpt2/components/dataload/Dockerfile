#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM ubuntu:latest
WORKDIR /app

COPY ["dataload.sh", "/app"]
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y unzip

CMD ["/bin/bash", "/app/dataload.sh"]
