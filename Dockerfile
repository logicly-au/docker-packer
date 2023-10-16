FROM amazon/aws-cli:latest

ARG BUILDPLATFORM
ARG TARGETPLATFORM
ARG PLATFORM="linux_64bit"
ARG PACKER_VERSION="1.9.4"

VOLUME ["/work"]

WORKDIR /work

RUN yum -y update && yum -y install openssh-server openssh-clients yum-utils gcc make zlib1g-dev wget curl tar unzip genisoimage

RUN if [[ "$TARGETPLATFORM" == "linux/arm64" ]]; then PLATFORM="linux_arm64"; fi; \
    curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/$PLATFORM/session-manager-plugin.rpm" -o "session-manager-plugin.rpm" && \
    yum install -y session-manager-plugin.rpm && \
    rm -rf session-manager-plugin.rpm && \
    yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo && \
    yum clean all

RUN amazon-linux-extras enable python3.8 && \
    yum clean metadata && \
    yum install -y python38 && \
    rm -rf /usr/bin/python && \
    ln -s /usr/bin/python3 /usr/bin/python

RUN wget https://bootstrap.pypa.io/pip/get-pip.py && \
    /usr/bin/python3.8 get-pip.py  && \
    rm get-pip.py && \
    pip3 install --no-cache-dir ansible paramiko hvac

RUN wget "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip" && \
    unzip "packer_${PACKER_VERSION}_linux_amd64.zip" && \
    mv packer /usr/bin/packer && \
    rm /usr/sbin/packer && \
    ln -s /usr/bin/packer /usr/sbin/packer && \
    rm -rf "packer_${PACKER_VERSION}_linux_amd64.zip"

ENTRYPOINT [ "packer" ]

CMD [ "--version" ]
