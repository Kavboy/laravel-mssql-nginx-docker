FROM mcr.microsoft.com/mssql/server:2017-latest

ENV SA_PASSWORD=Password1234
ENV ACCEPT_EULA=Y

RUN locale-gen en_US.UTF-8 && update-locale
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ADD ./entrypoint.sh /
ADD ./init.sh /

RUN  chmod +x /entrypoint.sh
RUN  chmod +x /init.sh

EXPOSE 1433

ENTRYPOINT /bin/bash ./entrypoint.sh
