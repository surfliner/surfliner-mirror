# Starlight

Starlight is a Helm chart that leverages the [starlight][starlight] container
image to support easy deployment via Helm and Kubernetes.

## TL;DR;

```console
$ git clone https://gitlab.com/surfliner/surfliner.git
$ helm dep update charts/starlight
$ helm install my-release charts/starlight
```

## Introduction

This chart bootstraps a [starlight][starlight] deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Installing the Chart
To install the chart with the release name `my-release`:

```console
$ helm install my-release charts/starlight
```

The command deploys Starlight on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

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
| `image.repository` | starlight image repository | `registry.gitlab.com/surfliner/surfliner/starlight_web` | N/A |
| `image.tag` | starlight image tag to use | `stable` | N/A |
| `image.pullPolicy` | starlight image pullPolicy | `Always` | N/A |
| `imagePullSecrets` | Array of pull secrets for the image | `[]` | N/A |
| `nameOverride` | String to partially override starlight.fullname template with a string (will prepend the release name) | `""` | N/A |
| `fullnameOverride` | String to fully override email.fullname template | `""` | N/A |
| `starlight.application.name` | Name used in some default Blacklight templates | `Starlight` | N/A |
| `starlight.application.themes` | Themes made available to the application.  | `ucsb,surfliner,ucsd` | `SPOTLIGHT_THEMES` |
| `starlight.rails.db_adapter` | Which Rails database adapter to use | `postgresql` | `DB_ADAPTER` |
| `starlight.rails.db_setup_command` | Database rake task(s) to run when deployment starts | `db:migrate` | `DATABASE_COMMAND` |
| `starlight.rails.environment` | Rails environment for application.  | `production` | `RAILS_ENV` |
| `starlight.rails.log_to_stdout` | Should Rails log to standard output.  | `true` | `RAILS_LOG_TO_STDOUT` |
| `starlight.rails.max_threads` | Size of DB connection pool (used by Sidekiq also).  | `5` | `RAILS_MAX_THREADS ` |
| `starlight.rails.queue` | Which queue adapter for ActiveJob.  | `sidekiq` | `RAILS_QUEUE` |
| `starlight.rails.serve_static_files` | Whether Rails should not serve files in `public/`.  | `true` | `RAILS_SERVE_STATIC_FILES` |
| `starlight.sitemap.enabled` | Whether to enable k8s sitemap cron job to ping search engines.  | `true` | N/A |
| `starlight.solr.collectionName` | Name of Solr collection.  | `collection1` | `SOLR_CORE_NAME` |
| `starlight.solr.port` | Solr port to use.  | `8983` | `SOLR_PORT` |
| `starlight.zookeeper.port` | Zookeeper port to use.  | `2181` | `ZK_PORT` |
| `starlight.backups.import.enabled` | Whether to run the backup import migration jobs (when migrating data from another environment).  | `false` | N/A |
| `starlight.backups.import.oldAppUrl` | URL for previous environment.  | `nil` | `OLD_APP_URL` |
| `starlight.backups.export.enabled` | Whether to run the backup export migration jobs.  | `false` | N/A |
| `starlight.backups.accessKey` | S3/Minio access key.  | `nil` | `AWS_ACCESS_KEY_ID` |
| `starlight.backups.secretKey` | S3/Minio .  | `nil` | `AWS_SECRET_ACCESS_KEY` |
| `starlight.backups.directoryImportPath` | Path to mount public/uploads backup directory into.  | `nil` | `DIRECTORY_IMPORT_PATH` |
| `starlight.backups.endpointUrl` | S3/Minio endpoint.  | `nil` | `ENDPOINT_URL` |
| `starlight.backups.bucket` | S3/Minio bucket name.  | `nil` | `BUCKET` |
| `starlight.backups.dbBucketKey` | S3/Minio database bump key/file.  | `nil` | `DB_BUCKET_KEY` |
| `starlight.backups.directoryBucketPath` | S3/Minio path to images backup in bucket.  | `nil` | `DIRECTORY_BUCKET_PATH` |
| `starlight.email.from_address` | Email address to use for Starlight email contact.  | `Starlight@example.edu` | `FROM_EMAIL` |
| `starlight.email.delivery_method` | ActiveMailer email submission method. Use `smtp` for production. | `letter_opener_web` | `DELIVERY_METHOD` |
| `starlight.email.smtp_settings.address` | SMTP server address.  | `nil` | `SMTP_HOST` |
| `starlight.email.smtp_settings.port` | SMTP server port.  | `nil` | `SMTP_PORT` |
| `starlight.email.smtp_settings.user_name` | SMTP account username.  | `nil` | `SMTP_USERNAME` |
| `starlight.email.smtp_settings.password` | SMTP account password.  | `nil` | `SMTP_PASSWORD` |
| `starlight.email.smtp_settings.authentication` | ActiveMailer SMTP auth method.  | `nil` | `SMTP_AUTHENTICATION` |
| `starlight.auth.method` | Application authentication method (`google` or `developer`).  | `developer` | `AUTH_METHOD` |
| `starlight.auth.google.api_id` | Google authentication API identifier.  | `nil` | `GOOGLE_AUTH_ID` |
| `starlight.auth.google.secret` | Google authentication API secret.  | `nil` | `GOOGLE_AUTH_SECRET` |
| `persistence.enabled` | Whether to create persistent volume claims(PVC) for the application.  | `true` | N/A |
| `persistence.public.size` | Rails public PVC size.  | `5Gi` | N/A |
| `persistence.public.class` | StorageClassName for your k8s cluster.  | `nil` | N/A |

### Chart Dependency Parameters

The following tables list a few key configurable parameters for Starlight chart dependencies and their default values. If you want to further customize the dependent chart, please consult the links below for the documentation of those charts.

#### Memcached

See: https://github.com/kubernetes/charts/blob/master/stable/memcached/README.md

| Parameter | Description | Default | Environment Variable |
| --------- | ----------- | ------- | -------------------- |
| `memcached.enabled` | Whether to use memcached for Rails cache_store | `true` | N/A |
| `memcached.architecture` | Which memcached architecture to deploy | `high-availability` | N/A |
| `memcached.persistence.enabled` | Whether to use a PVC (requires `high-availability` architecture) | `true` | N/A |
| `memcached.persistence.size` | Memcached PVC size| `8Gi` | N/A |

#### PostgreSQL

See: https://github.com/kubernetes/charts/blob/master/stable/postgresql/README.md

| Parameter | Description | Default | Environment Variable |
| --------- | ----------- | ------- | -------------------- |
| `postgresql.postgresqlUsername` | Database user for application | `starlight` | `POSTGRES_USER` |
| `postgresql.postgresqlPassword` | Database user password for application | `starlight_pass` | `POSTGRES_PASSWORD` |
| `postgresql.postgresqlDatabase` | Database name for application | `starlight_db` | `POSTGRES_DB` |
| `postgresql.postgresqlPostgresPassword` | Admin `postgres` user's password | `starlight_admin` | `POSTGRES_ADMIN_PASSWORD` |
| `postgresql.persistence.size` | Database PVC size | `10Gi` | N/A |

#### Solr

See: https://github.com/helm/charts/blob/master/incubator/solr/values.yaml

#### Redis

See: https://github.com/helm/charts/blob/master/stable/redis/README.md

[starlight]:https://gitlab.com/surfliner/surfliner/-/tree/trunk/starlight
