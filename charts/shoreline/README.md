# Shoreline

Shoreline is a Helm chart that leverages the [shoreline][shoreline] container
image to support easy deployment via Helm and Kubernetes.

## TL;DR;

```console
$ git clone https://gitlab.com/surfliner/surfliner.git
$ helm dep update charts/shoreline
$ helm install my-release charts/shoreline
```

## Introduction

This chart bootstraps a [shoreline][shoreline] deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Installing the Chart
To install the chart with the release name `my-release`:

```console
$ helm install my-release charts/shoreline
```

The command deploys Shoreline on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

The following tables lists the configurable parameters of the Shoreline chart and their default values, in addition to chart-specific options.

| Parameter | Description | Default | Environment Variable |
| --------- | ----------- | ------- | -------------------- |
| `image.repository` | shoreline image repository | `registry.gitlab.com/surfliner/surfliner/shoreline_discovery_app` | N/A |
| `image.tag` | shoreline image tag to use | `stable` | N/A |
| `image.pullPolicy` | shoreline image pullPolicy | `Always` | N/A |
| `imagePullSecrets` | Array of pull secrets for the image | `[]` | N/A |
| `nameOverride` | String to partially override shoreline.fullname template with a string (will prepend the release name) | `""` | N/A |
| `fullnameOverride` | String to fully override email.fullname template | `""` | N/A |
| `shoreline.access` | Specify the access level for the object being ingested: “Public” or “Restricted” | `Public` | `SHORELINE_ACCESS` |
| `shoreline.db_setup_command.name` | Database rake command to run on install/upgrade | `db:migrate` | `DATABASE_COMMAND` |
| `shoreline.geoblacklightDownloadPath` | Directory where GeoBlacklight stores generated files for download | `db:migrate` | `DATABASE_COMMAND` |
| `shoreline.provenance` | Specify the source of the object being ingested. e.g. "UC Santa Barbara" | `"UC Santa Barbara"` | `SHORELINE_PROVENANCE` |
| `shoreline.theme` | Shoreline theme to apply to deployment | `""` | `SHORELINE_THEME` |
| `shoreline.sample_data` | Whether to ingest sample/fixture data during deployment | `nil` | N/A |
| `shoreline.suppressTools` | Don't render the `Tools` pand on object view page | `false` | `SHORELINE_SUPPRESS_TOOLS` |
| `shoreline.solr.collectionName` | Solr collection name to use for application | `collection1` | `SOLR_CORE_NAME` |
| `shoreline.email.contact_email` | Email address for Contact form | `shoreline@example.edu` | `CONTACT_EMAIL` |
| `shoreline.email.delivery_method` | Rails ActionMailer delivery method. e.g. `smtp` | `letter_opener_web` | `DELIVERY_METHOD` |
| `shoreline.email.smtp_settings.address` | Rails ActionMailer delivery method. e.g. `smtp` | `letter_opener_web` | `DELIVERY_METHOD` |
| `shoreline.email.smtp_settings.address` | SMTP server address.  | `nil` | `SMTP_HOST` |
| `shoreline.email.smtp_settings.port` | SMTP server port.  | `nil` | `SMTP_PORT` |
| `shoreline.email.smtp_settings.user_name` | SMTP account username.  | `nil` | `SMTP_USERNAME` |
| `shoreline.email.smtp_settings.password` | SMTP account password.  | `nil` | `SMTP_PASSWORD` |
| `shoreline.email.smtp_settings.authentication` | ActiveMailer SMTP auth method.  | `nil` | `SMTP_AUTHENTICATION` |

### Chart Dependency Parameters

The following tables list a few key configurable parameters for Shoreline chart dependencies and their default values. If you want to further customize the dependent chart, please consult the links below for the documentation of those charts.

#### GeoServer

See: [Geoserver values.yaml](../geoserver/values.yaml)

| Parameter | Description | Default | Environment Variable |
| --------- | ----------- | ------- | -------------------- |
| `geoserver.admin.password` | Admin password for GeoServer | `shorelinegeo` | `GEOSERVER_PASSWORD` |
| `geoserver.persistence.enabled` | Whether to create a persistent volume claim for GeoServer data | `true` | N/A |

#### PostgreSQL

See: https://github.com/kubernetes/charts/blob/master/stable/postgresql/README.md

| Parameter | Description | Default | Environment Variable |
| --------- | ----------- | ------- | -------------------- |
| `postgresql.postgresqlUsername` | Database user for application | `shoreline-discovery` | `POSTGRES_USER` |
| `postgresql.postgresqlPassword` | Database user password for application | `shorelinepass` | `POSTGRES_PASSWORD` |
| `postgresql.postgresqlDatabase` | Database name for application | `shoreline-discovery` | `POSTGRES_DB` |
| `postgresql.persistence.size` | Database PVC size | `10Gi` | N/A |

#### Solr

See: https://github.com/helm/charts/blob/master/incubator/solr/values.yaml

[shoreline]:https://gitlab.com/surfliner/surfliner/-/tree/trunk/shoreline/discovery
