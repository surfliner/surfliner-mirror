# Orange Empire

Orange Empire is a Helm chart that leverages a [cantaloupe][cantaloupe] container
image to support easy deployment via Helm and Kubernetes.

## TL;DR;

```console
$ git clone https://gitlab.com/surfliner/surfliner.git
$ helm install my-release charts/orange-empire
```

## Introduction

This chart bootstraps a [cantaloupe][cantaloupe] deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Installing the Chart
To install the chart with the release name `my-release`:

```console
$ helm install my-release charts/orange-empire
```

The command deploys Orange Empire on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

The following tables lists the configurable parameters of the Starlight chart and their default values, in addition to chart-specific options.

There are several cantaloupe environment variables that can be updated.

see: https://github.com/UCLALibrary/docker-cantaloupe/tree/main/src/main/docker/configs

| Parameter | Description | Default | Environment Variable |
| --------- | ----------- | ------- | -------------------- |
| `image.repository` | starlight image repository | `registry.gitlab.com/surfliner/surfliner/starlight_web` | N/A |
| `image.tag` | starlight image tag to use | `4.1.5` | N/A |
| `image.pullPolicy` | starlight image pullPolicy | `Always` | N/A |
| `imagePullSecrets` | Array of pull secrets for the image | `[]` | N/A |
| `nameOverride` | String to partially override starlight.fullname template with a string (will prepend the release name) | `""` | N/A |
| `cantaloupe.admin.endpointEnabled` | Whether to enable the admin user and UI| `true` | `CANTALOUPE_ENDPOINT_ADMIN_ENABLED` |
| `cantaloupe.admin.secret` | Admin password/secret to access admin UI endpoint | `admin-password` | `CANTALOUPE_ENDPOINT_ADMIN_SECRET` |
| `cantaloupe.cacheServer.derivative` | Derivative storage source | `S3Cache` | `CANTALOUPE_CACHE_SERVER_DERIVATIVE` |
| `cantaloupe.cacheServer.derivativeEnabled` | Enable caching derivatives | `false` | `CANTALOUPE_ENDPOINT_ADMIN_ENABLED` |
| `cantaloupe.cacheServer.derivativeTTLSeconds` | TTL in seconds for derivatives | `3600` | `CANTALOUPE_CACHE_SERVER_DERIVATIVE_TTL_SECONDS` |
| `cantaloupe.cacheServer.purgeMissing` | TBD | `true` | `CANTALOUPE_CACHE_SERVER_PURGE_MISSING` |
| `cantaloupe.processorSelectionStrategy` | Processor selection strategy | `ManualSelectionStrategy` | `CANTALOUPE_PROCESSOR_SELECTION_STRATEGY` |
| `cantaloupe.sourceStatic` | Storage source for static files | `S3Source` | `CANTALOUPE_SOURCE_STATIC` |
| `cantaloupe.java.heapSize` | Customize Java Heap size | `1g` | `JAVA_HEAP_SIZE` |
| `cantaloupe.s3.cache.accessKeyId` | S3Cache access key id | `nil` | `CANTALOUPE_S3CACHE_ACCESS_KEY_ID` |
| `cantaloupe.s3.cache.bucketName` | S3Cache bucket name | `nil` | `CANTALOUPE_S3CACHE_BUCKET_NAME` |
| `cantaloupe.s3.cache.endpoint` | S3Cache endpoint URL | `nil` | `CANTALOUPE_S3CACHE_ENDPOINT` |
| `cantaloupe.s3.cache.secretKey` | S3Cache secret key | `nil` | `CANTALOUPE_S3CACHE_SECRET_KEY` |
| `cantaloupe.s3.source.accessKeyId` | S3Source access key id | `nil` | `CANTALOUPE_S3SOURCE_ACCESS_KEY_ID` |
| `cantaloupe.s3.source.basicLookupStrategyPathSuffix` | S3Source lookup strategy suffix | `.jpx` | `CANTALOUPE_S3SOURCE_BASICLOOKUPSTRATEGY_PATH_SUFFIX` |
| `cantaloupe.s3.source.bucketName` | S3Source bucket name | `nil` | `CANTALOUPE_S3SOURCE_BASICLOOKUPSTRATEGY_BUCKET_NAME` |
| `cantaloupe.s3.source.endpoint` | S3Source endpoint URL | `nil` | `CANTALOUPE_S3SOURCE_ENDPOINT` |
| `cantaloupe.s3.source.secretKey` | S3Source secret key | `nil` | `CANTALOUPE_S3SOURCE_SECRET_KEY` |

[cantaloupe]:https://github.com/UCLALibrary/docker-cantaloupe
