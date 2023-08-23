FROM openresty/openresty:1.21.4.1-0-bullseye-fat

RUN cat /etc/os-release

ENV TZ=Asia/Shanghai
ENV LANG=en_US.UTF-8
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo 'Asia/Shanghai' >/etc/timezone

# https://mirrors.tuna.tsinghua.edu.cn/help/debian/
RUN echo '\
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye main contrib non-free\n\
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye main contrib non-free\n\
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-updates main contrib non-free\n\
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-updates main contrib non-free\n\
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-backports main contrib non-free\n\
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-backports main contrib non-free\n\
deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bullseye-security main contrib non-free\n\
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian-security bullseye-security main contrib non-free\n\
' > /etc/apt/sources.list

RUN apt-get update
RUN apt-get install -y telnet

# Nginx 目录风格
# COPY somersault-cloud-ui-admin/dist /usr/share/nginx/html/admin
# OpenResty 目录风格
COPY somersault-cloud-ui-admin/dist /usr/local/openresty/nginx/html/admin
RUN ls -lh /usr/local/openresty/nginx/html/admin
COPY somersault-cloud-ui-app/dist/build/h5 /usr/local/openresty/nginx/html/h5
RUN ls -lh /usr/local/openresty/nginx/html/h5

COPY docker-openresty-entrypoint.sh /run/docker-openresty-entrypoint.sh
RUN chmod +x /run/docker-openresty-entrypoint.sh

ENTRYPOINT /run/docker-openresty-entrypoint.sh

