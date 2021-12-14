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
| `shoreline.disableSolrConfigInit` | Boolean flag to override use of the init container that manages the configset and collection via the Solr Cloud APIs | false | N/A |
| `shoreline.db_setup_command.name` | Database rake command to run on install/upgrade | `db:migrate` | `DATABASE_COMMAND` |
| `shoreline.geoblacklightDownloadPath` | Directory where GeoBlacklight stores generated files for download | `db:migrate` | `DATABASE_COMMAND` |
| `shoreline.theme` | Shoreline theme to apply to deployment | `""` | `SHORELINE_THEME` |
| `shoreline.sample_data` | Whether to ingest sample/fixture data during deployment | `nil` | N/A |
| `shoreline.suppressTools` | Don't render the `Tools` pand on object view page | `false` | `SHORELINE_SUPPRESS_TOOLS` |
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

| Parameter | Description | Default | Environment Variable |
| --------- | ----------- | ------- | -------------------- |
| `solrRunMode` | Defines if the instance of Solr is running in `cloud` or `standalone` mode; only used when `solr.enabled` is `false` | `cloud` | N/A |
| `solr.enabled` | Defines if this chart should provision/configure Solr using the dependency chart | `true` | N/A |
| `solr.solrHostname` | Defines the hostname of the server running Solr (only set if `solr.enabled` is `false`) | `nil` | `SOLR_HOST` |
| `solr.solrPort` | Defines the network port Solr can be accessed (only set if `solr.enabled` is `false`) | `8983` | `SOLR_PORT` |
| `solr.zookeeperHostname` | Defines the hostname of the server running Zookeeper (only set if `solr.enabled` is `false` and `solrRunMode` is `cloud`) | `nil` | `ZK_HOST` |
| `solr.zookeeperPort` | Defines the network port Zookeeper can be accessed (only set if `solr.enabled` is `false` and `solrRunMode` is `cloud`) | `2181` | `ZK_PORT` |
| `solr.collection` | Solr collection name to use for application (used only if `solrRunMode` is `cloud`) | `collection1` | `SOLR_CORE_NAME` |
| `solr.coreName` | Solr core name to use for application (used only if `solrRunMode` is `standalone`) | `shoreline` | `SOLR_CORE_NAME` |
| `solr.authentication.enabled` | Defines if the instance of Solr has Basic Authentication enabled | `true` | N/A |
| `solr.authentication.adminUsername` | Defines the admin username for Solr Basic Authentication (only set if `solr.authentication.enabled` is `true`) | `admin` | `SOLR_ADMIN_USER` |
| `solr.authentication.adminPassword` | Defines the admin password for Solr Basic Authenticaiton (only set if `solr.authentication.enabled` is `true`) | `admin` | `SOLR_ADMIN_PASSWORD` |

**SolrCloud vs. Standalone Solr**

You have the option to run an instance of Solr either as a part of the helm install or not managed by the chart (external). This is configured using the `solr.enabled` value.

When set to `true`, the Solr environment that comes with the chart is SolrCloud, and the chart will automatically set-up and configure the application to integrate with this instance.

When set to `false`, you have the option to run an instance of Solr using either SolrCloud or standalone. This is configured using the `solrRunMode` value. You also need to set additional values to configure the application to integrate with the external Solr instance (reference the solr parameters chart above).

Differences to note about SolrCloud and Standalone:
- Collections versus Cores
  - SolrCloud uses the concept of _collections_ whereas Standalone uses _cores_. This is why we have the two values `solr.collectionName` and `solr.coreName` - be sure to se these accordingly.
- Zookeeper
  - SolrCloud comprises a set of Solr nodes and Zookeeper nodes. If you are running Standalone Solr, zookeeper nodes are not present and those values are not needed.

**Solr Authentication**

If you are using an external Solr environment, you have the option to use or disable Basic Authentication for the appliation to access Solr. Be sure to set the `solr.authentication` appropriately.
