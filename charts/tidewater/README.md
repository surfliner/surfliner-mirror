# Tidewater

Tidewater is a Helm chart that leverages the [something][something] container
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

The following tables lists the configurable parameters of the Starlight chart and their default values, in addition to chart-specific options.

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
| `tidewater.allow_robots` | Whether to allow robots to crawl the application via `robots.txt` | `false` | `ALLOW_ROBOTS` |
| `tidewater.application.name` | Name used in some default Blacklight templates | `Tidewater` | N/A |
| `tidewater.application.themes` | Themes made available to the application.  | `ucsb,surfliner,ucsd` | `SPOTLIGHT_THEMES` |
| `tidewater.analytics.webPropertyId` | Your GA Property ID. Example: `UA-1234568-1`.  | `nil` | `GA_WEB_PROPERTY_ID` |
| `tidewater.rails.db_adapter` | Which Rails database adapter to use | `postgresql` | `DB_ADAPTER` |
| `tidewater.rails.db_setup_command` | Database rake task(s) to run when deployment starts | `db:migrate` | `DATABASE_COMMAND` |
| `tidewater.rails.environment` | Rails environment for application.  | `production` | `RAILS_ENV` |
| `tidewater.rails.log_to_stdout` | Should Rails log to standard output.  | `true` | `RAILS_LOG_TO_STDOUT` |
| `tidewater.rails.max_threads` | Size of DB connection pool (used by Sidekiq also).  | `5` | `RAILS_MAX_THREADS ` |
| `tidewater.rails.queue` | Which queue adapter for ActiveJob.  | `sidekiq` | `RAILS_QUEUE` |
| `tidewater.rails.serve_static_files` | Whether Rails should not serve files in `public/`.  | `true` | `RAILS_SERVE_STATIC_FILES` |

### Chart Dependency Parameters

The following tables list a few key configurable parameters for Starlight chart dependencies and their default values. If you want to further customize the dependent chart, please consult the links below for the documentation of those charts.

#### PostgreSQL

See: https://github.com/kubernetes/charts/blob/master/stable/postgresql/README.md

| Parameter | Description | Default | Environment Variable |
| --------- | ----------- | ------- | -------------------- |
| `postgresql.postgresqlUsername` | Database user for application | `tidewater` | `POSTGRES_USER` |
| `postgresql.postgresqlPassword` | Database user password for application | `tidewater_pass` | `POSTGRES_PASSWORD` |
| `postgresql.postgresqlHostname` | External database hostname, when `postgresql.enabled` is `false` | `nil` | `POSTGRES_HOST` |
| `postgresql.postgresqlDatabase` | Database name for application | `tidewater_db` | `POSTGRES_DB` |
| `postgresql.postgresqlPostgresPassword` | Admin `postgres` user's password | `tidewater_admin` | `POSTGRES_ADMIN_PASSWORD` |
| `postgresql.persistence.size` | Database PVC size | `10Gi` | N/A |
```

[tidewater]:https://gitlab.com/surfliner/surfliner/-/tree/trunk/tidewater
