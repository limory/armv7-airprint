FROM debian:stable-slim AS base
LABEL maintainer="Limory" \
      version="0.3" \
      description="Airprint for Canon" \
      source="https://github.com/limory/hi3798mv100-server-tools"

RUN apt-get update && apt-get install -y --no-install-recommends \
	locales \
#	brother-lpr-drivers-extra brother-cups-wrapper-extra \
#	printer-driver-splix \
	printer-driver-gutenprint \
	gutenprint-doc \
	gutenprint-locales \
	libgutenprint9 \
	libgutenprint-doc \
	ghostscript \
#	hplip \
	cups \
	cups-pdf \
	cups-client \
	cups-filters \
	inotify-tools \
	avahi-daemon \
	avahi-discover \
	python3 \
	python3-dev \
	python3-pip \
	python3-cups \
	wget \
	rsync && \
    apt-get autoremove -y && apt-get clean && apt-get autoclean && \
    rm -rf /var/lib/apt/lists/*

#新建空镜像装入基础镜像
#FROM scratch
#COPY --from=base / /
ENV TZ=Asia/Shanghai
# This will use port 631
EXPOSE 631
# We want a mount for these
VOLUME /config
VOLUME /services
# Add scripts
ADD root /

# Baked-in config file changes
RUN chmod +x /root/* && \ 
    sed -i 's/Listen localhost:631/Listen *:631/' /etc/cups/cupsd.conf && \
	sed -i 's/Browsing No/Browsing On/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
	sed -i 's/.*enable\-dbus=.*/enable\-dbus\=no/' /etc/avahi/avahi-daemon.conf && \
	echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
	echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf && \
	echo "BrowseWebIF Yes" >> /etc/cups/cupsd.conf

#Run Script
CMD ["/root/run_cups.sh"]

#build
#docker build -t cups-airprint:v1 .
#usage
#docker run -itd -v /opt/airprint/config:/config -v /opt/airprint/services:/services --device=/dev/bus --net=host --restart=on-failure:3 --name airprint cups-airprint:v1
