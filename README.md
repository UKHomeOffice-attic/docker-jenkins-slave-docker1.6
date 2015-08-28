# Jenkins Slave Docker Container: Docker 1.6.1

This container is an Jenkins slave with Docker 1.6.1. It extends the 
[Jenkins Slave Docker Container][1] by adding Docker 1.6.1.

It will also restore your docker authentication from an encrypted file in a S3 bucket.

[1]: https://github.com/UKHomeOffice/docker-jenkins-slave "Jenkins Slave Docker Container"

## Getting Started

In this section I'll show you some examples of how you might run this container with docker.

### Prerequisities

In order to run this container you'll need docker installed.

* [Windows](https://docs.docker.com/windows/started)
* [OS X](https://docs.docker.com/mac/started/)
* [Linux](https://docs.docker.com/linux/started/)

You'll also need a jenkins master with a node configured on it, that doesn't already have a slave 
connected to it.

There is a guide [on the jenkins wiki on how to do that][2] on how to do that. You'll only need to 
go up to step 4 though.

The Remote FS Root you want will be `/home/jenkins`

[2]: https://wiki.jenkins-ci.org/display/JENKINS/Step+by+step+guide+to+set+up+master+and+slave+machines "Step by step guide to set up master and slave machines"

### Encrypting your docker credentials

**Warning:** Make sure you do this on Docker 1.6. In Docker 1.7 and greater the authentication scheme
and file location changed. If you try to encrypt the authentication from 1.7 or high and try to use 
them with this container, it *will not work*.

The easiest way to do this is to login to docker on a machine. This will create a config file with
plaintext docker authentication details.

```
Usage: docker login [OPTIONS] [SERVER]

Register or log in to a Docker registry server, if no server is
specified "https://index.docker.io/v1/" is the default.

  -e, --email=""       Email
  -p, --password=""    Password
  -u, --username=""    Username
```

Next install the amazon commandline tools on the machine you have the plaintext docker 
authentication details. You can see how for your environment on the 
[AWS Command Line Interface page](https://aws.amazon.com/cli/).

In [IAM](https://aws.amazon.com/iam/) in AWS create the key you wish to use to encrypt the login 
details.

The on the machine you have the plain text docker authentication run this. In the meta information 
that is embedded in this encrypted file, is the key used. So you won't have to provide it again, but
you will have to provide the region the key is in in AWS.

```shell
aws kms encrypt --key-id the1-amaz-onke-y123 \
                --plaintext "$(cat ~/.dockercfg)" \
                --query CiphertextBlob \
                --output text \
    | base64 -D \ 
    > dockercfg.encrypted
```

Then upload dockercfg.encrypted to your desired bucket

```shell
ams s3 cp dockercfg.encrypted s3://yourbucket/dockercfg.encrypted
```

## Usage

### Environment Variables

* `AWS_KEY_REGION` - The region the key was in that you used to encrypt your docker login details 
  was created in
* `SECRETS_BUCKET` - The bucket you stored your dockercfg.encrypted in
* `AWS_ACCESS_KEY_ID` - The AWS Access Key ID for an AWS IAM user with permissions to download from 
  the bucket defined in `SECRETS_BUCKET`
* `AWS_SECRET_ACCESS_KEY` - The same users Secret Access Key.

### Volumes

* `/var/run/docker.sock` - You will need to mount the docker socket on the host to `/var/run/docker.sock` in order to be 
  able to use docker in docker.
* `/home/jenkins` - The default location where jenkins things happen.

### Container Parameters

This container has two modes of operation, the first is jenkins slave mode.

In this mode you pass the container 3 parameters.

* `jenkins-slave` - To tell the container to run as a jenkins slave
* `http://jenkins-url:5321` - Jenkins URL
* `my-node` - The name you've given the node

This looks look a bit like this in docker

```shell
docker run -v /var/run/docker.sock:/var/run/docker.sock \
           -e "AWS_ACCESS_KEY_ID=IDIDIDIDIDIDIDIDID" \
           -e "AWS_SECRET_ACCESS_KEY=SECRETSECRETSECRETSECRET" \
           -e "AWS_KEY_REGION=am-zone-r1" \
           -e "SECRETS_BUCKET=secretbucket" \
           quay.io/ukhomeofficedigital/jenkins-slave-docker1.6:v0.1.0 \
           jenkins-slave \
           http://jenkins-url:5321 \
           my-node
```

The other mode of operation is simply to drop you into a bash shell on the container. For this just
run the command you want to execute as a parameter as normal. 

So if you wanted to run bash, you'd run this 

```shell
docker run -v /var/run/docker.sock:/var/run/docker.sock \
           -e "AWS_ACCESS_KEY_ID=IDIDIDIDIDIDIDIDID" \
           -e "AWS_SECRET_ACCESS_KEY=SECRETSECRETSECRETSECRET" \
           -e "AWS_KEY_REGION=am-zone-r1" \
           -e "SECRETS_BUCKET=secretbucket" \
           quay.io/ukhomeofficedigital/jenkins-slave-docker1.6:v0.1.0 \
           bash
```

### Kubernetes Example

You can find an example of the ReplicationController you might with this container in 
[examplekb8.rc.yml][3].

[3]: examplekb8.rc.yml "Kubernetes Replication Controller Example"
  
## Find Us

* [GitHub](https://github.com/UKHomeOffice/docker-jenkins-slave-docker1.6)
* [Quay.io](https://quay.io/repository/ukhomeofficedigital/jenkins-slave-docker1.6)

## Contributing

Feel free to submit pull requests and issues. If it's a particularly large PR, you may wish to 
discuss it in an issue first.

Please note that this project is released with a [Contributor Code of Conduct][4]. By participating 
in this project you agree to abide by its terms.

[4]: code_of_conduct.md "Contributor Code of Conduct"

## Versioning

We use [SemVer][5] for versioning. For the versions available, see the [tags on this repository][6].

[5]: http://semver.org/ "Semantic Versioning 2.0.0"
[6]: https://github.com/UKHomeOffice/docker-jenkins-slave-docker1.6/tags

## Authors

* **Billie Thompson** - *Initial work* - [purplebooth](https://github.com/purplebooth)

See also the list the of [contributors][7] who participated in this project.

[7]: https://github.com/UKHomeOffice/docker-jenkins-slave-docker1.6/graphs/contributors

## License

This project is licensed under the MIT License - see the [LICENSE.md][8] file for details

[8]: LICENSE.md "The MIT License (MIT)"
