FROM keloran/base-machine:latest
MAINTAINER Keloran <keloran@nordicarts.net>
LABEL Description="Blackfish"

# ENV Settings
ENV HOME /root
ENV WORK_DIR /root/code

# Work Directory
WORKDIR ${WORK_DIR}

# APT-GET
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y \
    net-tools \
    ssh-import-id \
    aptitude \
    mysql-server-5.6

RUN apt-get autoremove -y \
  && apt-get clean \
  && apt-get autoclean

# Remove bits not needed anymore
RUN apt-get remove --purge -y \
  software-properties-common \
  python-software-properties
RUN apt-get autoremove -y \
  && apt-get clean \
  && apt-get autoclean

# NGINX Config
RUN sed -i -e '/worker_processes/c\worker_processes 5;' /etc/nginx/nginx.conf \
  && sed -i -e '/keepalive_timeout/c\keepalive_timeout 2;' /etc/nginx/nginx.conf \
  && sed -i -e '/client_max_body_size/c\client_max_body_size 100m;' /etc/nginx/nginx.conf \
  && echo "daemon off;" >> /etc/nginx/nginx.conf

RUN rm -rf /etc/nginx/conf.d/* \
  && rm -rf /etc/nginx/sites-available/default \
  && rm -rf /etc/nginx/sites-enabled/default \
  && mkdir -p /etc/nginx/ssl
ADD Scripts/nginx-site.conf /etc/nginx/sites-available/default.conf

# Clean APT
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set lib path
ENV LD_LIBRARY_PATH /usr/local/lib:/usr/local/include:$LD_LIBRARY_PATH

# Set Path
ENV PATH /usr/bin/:${WORK_DIR}/:$PATH

# See if swift works
CMD ["/usr/bin/swift", "--version"]

# Add mount
VOLUME [${WORK_DIR}]

# SSH Stuffs
RUN mkdir -p -m 0700 /root/.ssh \
  && echo -e "Host *\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config \
  && ssh-import-id gh:Keloran

# Expose port
EXPOSE 22
EXPOSE 80

# Source
RUN mkdir ${WORK_DIR}/experiment

# SuperVisor
ADD Scripts/supervisord.conf /etc/supervisord.conf

# Scripts
ADD Scripts/start.sh /start.sh

# SiteBuild
ADD Scripts/SiteBuild.sh /SiteBuild.sh
RUN /bin/chmod +x /SiteBuild.sh

# Allow execution
RUN /bin/chmod +x /start.sh

# Keeps in memory
CMD ["/bin/bash", "/start.sh"]
