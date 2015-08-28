#!/bin/bash

download_secrets() {
  echo "Downloading secrets"
  mkdir /root/.secrets
  s3secrets --region ${AWS_KEY_REGION} \
            --bucket ${SECRETS_BUCKET} \
            --output-dir /root/.secrets

  echo "Secrets downloaded"
}

set_docker_login() {
  echo "Creating docker logins"
  mkdir /root/.docker
  # Note: this path changed in Docker 1.7 and greater.
  cp /root/.secrets/dockercfg /root/.dockercfg
  echo "Docker logins created successfully"
}

download_secrets
set_docker_login

exec /usr/local/bin/jenkins-slave.sh "$@"
