FROM ubuntu:latest

# Install linux packages
RUN apt update && apt install -y python3-pip zip htop screen
RUN alias python=python3 && alias pip=pip3

# 设置apt-get国内源
COPY ./sources.list /etc/apt/sources.list

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 871920D1991BC93C && \
    apt-get update && \
    apt-get upgrade -y

# 安装ssh
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

RUN apt-get install -y openssh-client && \
    apt-get install -y openssh-server

# 配置 ssh
RUN echo "root:passwd" | chpasswd && \
    sed -i '/#PermitRootLogin.*/a PermitRootLogin yes' /etc/ssh/sshd_config && \
    mkdir /var/run/sshd

# pip设置国内源
RUN pip3 config set global.index-url http://mirrors.aliyun.com/pypi/simple && \
    pip3 config set install.trusted-host mirrors.aliyun.com

# Install python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Create working directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]