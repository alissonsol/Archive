# Paths explored
# If using Windows containers: https://docs.microsoft.com/en-us/visualstudio/install/build-tools-container?view=vs-2019
# Linux
# Working on msbuild: https://github.com/dotnet/msbuild/blob/master/documentation/wiki/Building-Testing-and-Debugging-on-.Net-Core-MSBuild.md

FROM mcr.microsoft.com/dotnet/sdk:5.0
WORKDIR /workspace
COPY ./t/ /workspace
RUN apt-get update && \
    apt-get install -y build-essential
RUN apt-get install -y nuget mono-devel mono-xbuild

WORKDIR /app
COPY ["launch.sh", "/app"]
