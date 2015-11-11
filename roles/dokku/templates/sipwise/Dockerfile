MAINTAINER Sipwise Team <support@sipwise.com>
ENV REFRESHED_AT=20150309
RUN useradd --shell=/bin/bash --create-home sipwise
RUN echo sipwise:sipwise | chpasswd
RUN DEBIAN_FRONTEND=noninteractive apt-get --force-yes -y install sudo
RUN echo "sipwise ALL=NOPASSWD: ALL" > /etc/sudoers.d/sipwise
RUN wget -O /tmp/ngcp-installer.deb http://deb.sipwise.com/spce/ngcp-installer-mr3.7.2.deb
RUN dpkg -i /tmp/ngcp-installer.deb
RUN echo y | ngcp-installer 2>&1 | tee -a /tmp/ngcp-installer-debug.log
RUN apt-get clean
EXPOSE 22/tcp
EXPOSE 443/tcp
EXPOSE 1443/tcp
EXPOSE 2443/tcp
EXPOSE 1080/tcp
EXPOSE 5060/tcp
CMD [/sbin/init]
