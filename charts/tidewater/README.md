# Tidewater

Tidewater is a Helm chart that leverages the [tidewater][tidewater] container
image to support easy deployment via Helm and Kubernetes.


## TL;DR;

```console
$ git clone https://gitlab.com/surfliner/surfliner.git
$ helm dep update charts/tidewater
$ helm install my-release charts/tidewater
```

## Introduction

This chart bootstraps a [tidewater][tidewater] deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Installing the Chart
To install the chart with the release name `my-release`:

```console
$ helm install my-release charts/tidewater
```

The command deploys Tidewater on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

The following tables lists the configurable parameters of the Tidewater chart and their default values, in addition to chart-specific options.

### General

| Parameter | Description | Default | Environment Variable |
| --------- | ----------- | ------- | -------------------- |
| `image.repository` | tidewater image repository | `registry.gitlab.com/surfliner/surfliner/tidewater_web` | N/A |
| `image.tag` |  tidewater image tag to use | `stable` | N/A |
| `image.pullPolicy` | tidewater image pullPolicy | `Always` | N/A |
| `imagePullSecrets` | Array of pull secrets for the image | `[]` | N/A |
| `nameOverride` | String to partially override tidewater.fullname template with a string (will prepend the release name) | `""` | N/A |
| `fullnameOverride` | String to fully override email.fullname template | `""` | N/A |
| `existingSecret.name` | External Secret name in Deployment namespace | `tidewater` | N/A |
| `existingSecret.enabled` | Whether to use an external Secret for a Deployment | `false` | N/A |

### OAI-PMH Configuration

Configures the application to set some required configuration details for the
[OAI-PMH][oai-spec] [Repository][oai-repository] that the application will serve.

| Parameter | Description | Default | Environment Variable |
| --------- | ----------- | ------- | -------------------- |
| `oai.adminEmail` | E-mail address of an administrator of the repository | `tidewater@example.com` | `OAI_ADMIN_EMAIL` |
| `oai.metadataProfile` | Metadata profile used for requesting data from `superskunk` API | `tag:surfliner.gitlab.io,2022:api/oai_dc` | `OAI_METADATA_PROFILE` |
| `oai.repositoryName` | A human readable name for the repository | `tidewater` | `OAI_REPOSITORY_NAME` |
| `oai.sampleId` | `oai.namespaceIdentifier` will be automatically prepended to `oai.sample_id` | `13900` | `OAI_SAMPLE_ID` |
| `oai.namespaceIdentifier` | Unique namespace for items | `ingress.hosts[0]` | `OAI_NAMESPACE_IDENTIFIER` |

### Tidewater Rails Application

| Parameter | Description | Default | Environment Variable |
| --------- | ----------- | ------- | -------------------- |
| `rails.db_setup_command` | Database command to run on startup | `db:migrate` | `DATABASE_COMMAND` |
| `rails.environment` | Rails environment to use for deployment | `production` | `RAILS_ENV` |
| `rails.log_to_stdout` | Whether to have application log to `stdout` | `true` | `RAILS_LOG_TO_STDOUT` |
| `rails.max_threads` | Maximum threads to run for Puma server | `5` | `RAILS_MAX_THREADS` |
| `rails.serve_static_files` | Should rails serve static files | `true` | `RAILS_SERVE_STATIC_FILES` |

### Tidewater Consumer

The Tidewater chart also contains an optional `Deployment` template for the
tidewater consumer script. The purpose of this script is to listen and consume events published by Comet to a RabbitMQ cluster.

In order the facilitate enabling and configuring the consumer `Deployment` the
following parameters are available.

| Parameter | Description | Default | Environment Variable |
| --------- | ----------- | ------- | -------------------- |
| `consumer.enabled` | Flag to enable consumer | `true` | N/A |
| `consumer.replicaCount` | Number of consumer replicas | `1` | N/A |
| `consumer.logLevel` | [Logging level][logger-severity] to use for script | `info` | `LOG_LEVEL` |
| `consumer.existingSecret.name` | External Secret name in Deployment namespace for consumer | `tidewater-consumer` | N/A |
| `consumer.existingSecret.enabled` | Whether to use an external Secret for consumer | `false` | N/A |
| `consumer.rabbitmq.topic` | RabbitMQ topic to listen on | `surfliner.metadata` | `RABBITMQ_TOPIC` |
| `consumer.rabbitmq.host` | RabbitMQ host to connect to | `rabbitmq` | `RABBITMQ_HOST` |
| `consumer.rabbitmq.routing_key` | RabbitMQ routing_key for topic | `surfliner.metadata.tidewater` | `RABBITMQ_TIDEWATER_ROUTING_KEY` |
| `consumer.rabbitmq.username` | RabbitMQ username for connection | `surfliner` | `RABBITMQ_USERNAME` |
| `consumer.rabbitmq.password` | RabbitMQ password for connection | `surfliner` | `RABBITMQ_PASSWORD` |
| `consumer.rabbitmq.port` | RabbitMQ port for connection | `surfliner` | `RABBITMQ_NODE_PORT_NUMBER` |

### Tidewater Signing Keypair

In order to be able to successfully authenticate to the [Superskunk][superskunk]
application, tidewater needs to sign requests using a keypair. There is a
default keypair in a `Secret` template in the Helm chart, however for production
purposes it is expected that an external `Secret` will be created and referenced
by name as shown below.

To create that secret, you might do the following:

Create the key, let's assume we save it to `/tmp/tidwater`

```sh
$ ssh-keygen -t rsa -b 4096 -C "tidewater@ucsd.edu" -f /tmp/tidewater
$ ls /tmp
tidewater tidewater.pub
```

Create a `pem` (or `PKCS8`) public key:

```sh
$ ssh-keygen -f /tmp/tidewater -e -m pem > /tmp/tidewater-pem.pub
```

Create your secret by coping the template and replacing the `base64` encoded
values for the `ssh-publickey` and `ssh-privatekey`. For the `ssh-publickey` it
is important to use the `pem` or `PKCS8` public key. Note it's critical that the
`base64`-encoded value be on a single line (no newlines or carriage returns).

Example:

```sh
cat /tmp/tidewater-pem.pub | base64 -w0 | xclip
```

An alternative to hand-creating the `Secret` is to do it directly via the
command line. You might do something like:

```sh
kubectl -n tidewater-staging create secret generic surfliner-tidewater-staging-keypair --from-file=ssh-privatekey=/tmp/tidewater --from-file=ssh-publickey=/tmp/tidewater-pem.pub
```
| Parameter | Description | Default | Environment Variable |
| --------- | ----------- | ------- | -------------------- |
| `keypair.existingSecret.enabled` | Flag to use external Secret for keypair | `false` | N/A |
| `keypair.existingSecret.name` | Name of external Secret for keypair | `false` | N/A |
| `keypair.mountPath` | Directory on container to mount keypair | `/keys` | N/A |

### Chart Dependency Parameters

The following tables list a few key configurable parameters for Tidewater chart dependencies and their default values. If you want to further customize the dependent chart, please consult the links below for the documentation of those charts.

#### PostgreSQL

See: https://github.com/kubernetes/charts/blob/master/stable/postgresql/README.md

| Parameter | Description | Default | Environment Variable |
| --------- | ----------- | ------- | -------------------- |
| `postgresql.postgresqlUsername` | Database user for application | `tidewater` | `POSTGRESQL_USERNAME` |
| `postgresql.postgresqlPassword` | Database user password for application | `tidewater_pass` | `POSTGRESQL_PASSWORD` |
| `postgresql.postgresqlHostname` | External database hostname, when `postgresql.enabled` is `false` | `nil` | `POSTGRESQL_HOST` |
| `postgresql.postgresqlDatabase` | Database name for application | `tidewater_db` | `POSTGRESQL_DATABASE` |
| `postgresql.postgresqlPostgresPassword` | Admin `postgres` user's password | `tidewater_admin` | `POSTGRESQL_POSTGRES_PASSWORD` |
| `postgresql.persistence.size` | Database PVC size | `10Gi` | N/A |

[logger-severity]:https://ruby-doc.org/stdlib-3.0.0/libdoc/logger/rdoc/Logger/Severity.html
[oai-spec]:https://www.openarchives.org/OAI/openarchivesprotocol.html
[oai-repository]:https://www.openarchives.org/OAI/openarchivesprotocol.html#Repository
[tidewater]:https://gitlab.com/surfliner/surfliner/-/tree/trunk/tidewater
