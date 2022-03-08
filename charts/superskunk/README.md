# Superskunk

Superskunk is a Helm chart that leverages the [superskunk][superskunk] container
image to support easy deployment via Helm and Kubernetes.


## TL;DR;

```console
$ git clone https://gitlab.com/surfliner/surfliner.git
$ helm dep update charts/superskunk
$ helm install my-release charts/superskunk
```

## Introduction

This chart bootstraps a [superskunk][superskunk] deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Installing the Chart
To install the chart with the release name `my-release`:

```console
$ helm install my-release charts/superskunk
```

The command deploys Superskunk on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

The following tables lists the configurable parameters of the Superskunk chart and their default values, in addition to chart-specific options.

### General

| Parameter | Description | Default | Environment Variable |
| --------- | ----------- | ------- | -------------------- |
| `image.repository` | superskunk image repository | `registry.gitlab.com/surfliner/surfliner/superskunk` | N/A |
| `image.tag` |  superskunk image tag to use | `stable` | N/A |
| `image.pullPolicy` | superskunk image pullPolicy | `Always` | N/A |
| `imagePullSecrets` | Array of pull secrets for the image | `[]` | N/A |
| `nameOverride` | String to partially override superskunk.fullname template with a string (will prepend the release name) | `""` | N/A |
| `fullnameOverride` | String to fully override email.fullname template | `""` | N/A |
| `existingSecret.name` | External Secret name in Deployment namespace | `superskunk` | N/A |
| `existingSecret.enabled` | Whether to use an external Secret for a Deployment | `false` | N/A |

### Superskunk Consumers

| Parameter | Description | Default | Environment Variable |
| --------- | ----------- | ------- | -------------------- |
| `consumers.keysFileMountPath` | Path to mount file container app/key yaml file for application| `/config` | Used to populate `CONSUMER_KEYS_FILE` |
| `consumers.mountPath` | Path to mount consumer public keys | `/keys` | N/A |
| `consumers.publicKey` | Name of publicKey in the provided `Secrets` | `ssh-publickey` | N/A |
| `consumers.defaultKeyEnabled` | Whether to use the default provided key for `tidewater`. Used for review apps. | `false` | N/A |
| `consumers.keys` | Array of `name` and `secretName` pairs for each consumer | `nil` | N/A |

### Chart Dependency Parameters

The following tables list a few key configurable parameters for Superskunk chart dependencies and their default values. If you want to further customize the dependent chart, please consult the links below for the documentation of those charts.

#### PostgreSQL

See: https://github.com/kubernetes/charts/blob/master/stable/postgresql/README.md

| Parameter | Description | Default | Environment Variable |
| --------- | ----------- | ------- | -------------------- |
| `postgresql.postgresqlUsername` | Database user for application | `superskunk` | `POSTGRES_USER` |
| `postgresql.postgresqlPassword` | Database user password for application | `superskunk_pass` | `POSTGRES_PASSWORD` |
| `postgresql.postgresqlHostname` | External database hostname, when `postgresql.enabled` is `false` | `nil` | `POSTGRES_HOST` |
| `postgresql.postgresqlDatabase` | Database name for application | `superskunk_db` | `POSTGRES_DB` |
| `postgresql.postgresqlPostgresPassword` | Admin `postgres` user's password | `superskunk_admin` | `POSTGRES_ADMIN_PASSWORD` |
| `postgresql.persistence.size` | Database PVC size | `10Gi` | N/A |
```

[superskunk]:https://gitlab.com/surfliner/surfliner/-/tree/trunk/superskunk