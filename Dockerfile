FROM mcr.microsoft.com/dotnet/sdk:latest AS base
WORKDIR /app
EXPOSE 5000
ENV ASPNETCORE_URLS=http://*:5000

RUN git clone https://github.com/JimRoton/HelloWorld

WORKDIR /app/HelloWorld
RUN dotnet build -c Release -o /app/build
RUN dotnet publish -c Release -o /app/publish

ENTRYPOINT ["dotnet", "/app/publish/HelloWorld.dll"]
#ENTRYPOINT ["/bin/bash"]

