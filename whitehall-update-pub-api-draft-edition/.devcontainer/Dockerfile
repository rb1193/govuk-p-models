FROM ubuntu:jammy

WORKDIR /app

RUN apt-get update -qq
RUN apt-get install -y default-jre wget
RUN wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN rm packages-microsoft-prod.deb

RUN apt-get update -qq && apt-get install -y dotnet-sdk-8.0

RUN dotnet tool install --global P

RUN echo 'export PATH=$PATH:$HOME/.dotnet/tools' >> /root/.bashrc

CMD [ "/bin/bash" ]