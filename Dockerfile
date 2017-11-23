FROM ubuntu:16.04

ARG SEMUXVER="1.0.0-rc.3"

ENV DEBIAN_FRONTEND noninteractive

#RUN sed -i 's#http://archive.ubuntu.com/#http://tw.archive.ubuntu.com/#' /etc/apt/sources.list

# built-in packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends software-properties-common curl \
    && apt-get install -y --no-install-recommends\
        supervisor \
        pwgen sudo vim-tiny \
        net-tools \
        lxde x11vnc xvfb \
        nginx \
        python-pip python-dev build-essential \
        mesa-utils libgl1-mesa-dri \
        dbus-x11 x11-utils \
	default-jre\
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*


# tini for subreap                                   
ENV TINI_VERSION v0.9.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /bin/tini
RUN chmod +x /bin/tini

ADD image /
RUN pip install setuptools wheel && pip install -r /usr/lib/web/requirements.txt

EXPOSE 80 5161
WORKDIR /root
ENV HOME=/home/ubuntu \
    SHELL=/bin/bash

RUN curl -L https://github.com/semuxproject/semux/releases/download/v${SEMUXVER}/semux-${SEMUXVER}-unix.tar.gz -o /semux-${SEMUXVER}-unix.tar.gz 
RUN mkdir -p /semux && tar -xzf /semux-${SEMUXVER}-unix.tar.gz -C /semux --strip-components=1 && rm /semux-${SEMUXVER}-unix.tar.gz
RUN mkdir -p /root/Desktop && ln -s /semux /root/Desktop/semux
ENTRYPOINT ["/startup.sh"]
