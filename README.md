# armv7-airprint
基于 cups 构建 armv7 平台 airprint 瘦身 仅安装佳能Canon驱动  
#build  
#docker build -t cups-airprint:v1 .  
#usage  
#docker run -itd -v /opt/airprint/config:/config -v /opt/airprint/services:/services --device=/dev/bus --net=host --restart=on-failure:3 --name airprint cups-airprint:v1
