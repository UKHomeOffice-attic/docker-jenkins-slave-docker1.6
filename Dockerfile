FROM quay.io/ukhomeofficedigital/jenkins-slave:v0.2.0

COPY docker.repo /etc/yum.repos.d/docker.repo
RUN yum install -y epel-release && \
    yum install -y python-pip \
                   docker-1.6.2 && \
    yum clean all && \
    pip install awscli

COPY set-secrets.sh /usr/local/bin/set-secrets.sh

# Install S3 Secrets Tool
RUN URL=https://github.com/UKHomeOffice/s3secrets/releases/download/v0.0.1/s3secrets-0.0.1-linux-amd64 \
    OUTPUT_FILE=/usr/local/bin/s3secrets MD5SUM=aecf1a0d9c0a113432bb15bb10d16541 \
    /bin/bash -c 'until [[ -x ${OUTPUT_FILE} ]] && [[ $(md5sum ${OUTPUT_FILE} | cut -f1 -d" ") == ${MD5SUM} ]]; do \
        wget -q -O ${OUTPUT_FILE} ${URL} && \
        chmod +x ${OUTPUT_FILE}; \
    done'

ENTRYPOINT ["/usr/local/bin/set-secrets.sh"]
