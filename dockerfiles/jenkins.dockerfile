FROM jenkins/jenkins:lts

USER root

# Cài đặt các gói phụ thuộc
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    unzip \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common

# Cài đặt AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

# Cài đặt Skopeo
RUN apt-get update && \
    apt-get install -y skopeo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# Chuyển về user jenkins
USER jenkins
