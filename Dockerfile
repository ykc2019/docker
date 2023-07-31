# CLion remote docker environment (How to build docker container, run and stop it)
#
# Build and run:
#   docker build -t clion/remote-cpp-env:0.5 -f clion-docker .
#   docker run -d --cap-add sys_ptrace -p127.0.0.1:2223:22 --name clion_remote_env clion/remote-cpp-env:0.5
#   ssh-keygen -f "$HOME/.ssh/known_hosts" -R "[localhost]:2222"
#
# stop:
#   docker stop clion_remote_env
# 
# ssh credentials (test user):
#   user@password 

FROM ubuntu:20.04
ENV LANG en_US.utf8
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y locales  && apt-get install -y ssh \
      build-essential \
      gcc \
      g++ \
      gdb \
      clang \
      cmake \
      rsync \
      tar \
      python \
      nano \
      zip \
      libssl-dev \
      git \
      autoconf \ 
      libtool \ 
      make \
      execstack \
      sudo && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
   && apt-get clean 


 
 

RUN ( \
    echo 'LogLevel DEBUG2'; \
    echo 'PermitRootLogin yes'; \
    echo 'PasswordAuthentication yes'; \
    echo 'Subsystem sftp /usr/lib/openssh/sftp-server'; \
  ) > /etc/ssh/sshd_config_test_clion \
  && mkdir /run/sshd
RUN  ssh-keygen -A 
RUN useradd -m lora && yes Oracle09 | passwd lora && adduser lora sudo
USER lora 
RUN   cd /home/lora && git clone https://github.com/wolfSSL/wolfssl.git  
RUN   cd /home/lora/wolfssl && ./autogen.sh &&  ./configure --enable-static  --enable-dtls --enable-debug && make

USER root
RUN   cd /home/lora/wolfssl && make install

 
CMD ["/usr/sbin/sshd", "-D", "-e", "-f", "/etc/ssh/sshd_config_test_clion"]
EXPOSE 22/tcp
