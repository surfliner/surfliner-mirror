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
| `existingSecret.name` | External Secret name in Deployment namespace | `starlight` | N/A |
| `existingSecret.enabled` | Whether to use an external Secret for a Deployment | `false` | N/A |
| `starlight.allow_robots` | Whether to allow robots to crawl the application via `robots.txt` | `false` | `ALLOW_ROBOTS` |
| `starlight.application.name` | Name used in some default Blacklight templates | `Starlight` | N/A |
| `starlight.application.themes` | Themes made available to the application.  | `ucsb,surfliner,ucsd` | `SPOTLIGHT_THEMES` |
| `starlight.analytics.webPropertyId` | Your GA Property ID. Example: `UA-1234568-1`.  | `nil` | `GA_WEB_PROPERTY_ID` |
| `starlight.rails.db_adapter` | Which Rails database adapter to use | `postgresql` | `DB_ADAPTER` |
| `starlight.rails.db_setup_command` | Database rake task(s) to run when deployment starts | `db:migrate` | `DATABASE_COMMAND` |
| `starlight.rails.environment` | Rails environment for application.  | `production` | `RAILS_ENV` |
| `starlight.rails.log_to_stdout` | Should Rails log to standard output.  | `true` | `RAILS_LOG_TO_STDOUT` |
| `starlight.rails.max_threads` | Size of DB connection pool (used by Sidekiq also).  | `5` | `RAILS_MAX_THREADS ` |
| `starlight.rails.queue` | Which queue adapter for ActiveJob.  | `sidekiq` | `RAILS_QUEUE` |
| `starlight.rails.serve_static_files` | Whether Rails should not serve files in `public/`.  | `true` | `RAILS_SERVE_STATIC_FILES` |
| `starlight.sitemaps.enabled` | Whether to enable k8s sitemap cron job to ping search engines. Note that the sitemaps will upload to the same S3/Minio bucket specified by `starlight.storage.bucket` | `true` | N/A |
| `starlight.solr.collectionName` | Name of Solr collection.  | `collection1` | `SOLR_CORE_NAME` |
| `starlight.solr.port` | Solr port to use.  | `8983` | `SOLR_PORT` |
| `starlight.zookeeper.port` | Zookeeper port to use.  | `2181` | `ZK_PORT` |
| `starlight.backups.import.enabled` | Whether to run the backup import migration jobs (when migrating data from another environment).  | `false` | N/A |
| `starlight.backups.import.asset_host` | The new host from where images uploaded through the CMS will be served; used for rewriting URLs  | `nil` | `ASSET_HOST` |
| `starlight.backups.import.oldAppUrl` | URL for previous environment.  | `nil` | `OLD_APP_URL` |
| `starlight.backups.export.enabled` | Whether to run the backup export migration jobs.  | `false` | N/A |
| `starlight.backups.directoryImportPath` | Path to mount public/uploads backup directory into.  | `nil` | `DIRECTORY_IMPORT_PATH` |
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
| `starlight.storage.accessKey` | S3/Minio access key.  | `nil` | `AWS_ACCESS_KEY_ID` |
| `starlight.storage.acl` | S3/Minio ACL. e.g: 'bucket-owner-full-control'. | `nil` | `S3_ACL` |
| `starlight.storage.bucket` | S3/Minio bucket name. This bucket will need to allow write/put for the access keypair used, and public `read` access to allow for IIIF viewing. | `nil` | `S3_BUCKET_NAME` |
| `starlight.storage.endpointUrl` | S3/Minio endpoint URL (required for Minio).  | `nil` | `S3_ENDPOINT` |
| `starlight.storage.region` | AWS region. e.g: 'us-west-2'.  | `nil` | `AWS_REGION` |
| `starlight.storage.secretKey` | S3/Minio secret key. | `nil` | `AWS_SECRET_ACCESS_KEY` |

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
| `postgresql.postgresqlHostname` | External database hostname, when `postgresql.enabled` is `false` | `nil` | `POSTGRES_HOST` |
| `postgresql.postgresqlDatabase` | Database name for application | `starlight_db` | `POSTGRESQL_DATABASE` |
| `postgresql.postgresqlPostgresPassword` | Admin `postgres` user's password | `starlight_admin` | `POSTGRES_ADMIN_PASSWORD` |
| `postgresql.persistence.size` | Database PVC size | `10Gi` | N/A |

#### Solr

See: https://github.com/bitnami/charts/blob/master/bitnami/solr/values.yaml

| Parameter | Description | Default | Environment Variable |
| --------- | ----------- | ------- | -------------------- |
| `starlight.solrRunMode` | Defines if the instance of Solr is running in `cloud` or `standalone` mode; only used when `solr.enabled` is `false` | `cloud` | N/A |
| `solr.enabled` | Defines if this chart should provision/configure Solr using the dependency chart | `true` | N/A |
| `solr.solrHostname` | Defines the hostname of the server running Solr (only set if `solr.enabled` is `false`) | `nil` | `SOLR_HOST` |
| `solr.solrPort` | Defines the network port Solr can be accessed (only set if `solr.enabled` is `false`) | `8983` | `SOLR_PORT` |
| `solr.zookeeperHostname` | Defines the hostname of the server running Zookeeper (only set if `solr.enabled` is `false` and `starlight.solrRunMode` is `cloud`) | `nil` | `ZK_HOST` |
| `solr.zookeeperPort` | Defines the network port Zookeeper can be accessed (only set if `solr.enabled` is `false` and `starlight.solrRunMode` is `cloud`) | `2181` | `ZK_PORT` |
| `solr.collection` | Solr collection name to use for application (used only if `starlight.solrRunMode` is `cloud`) | `collection1` | `SOLR_CORE_NAME` |
| `solr.coreName` | Solr core name to use for application (used only if `starlight.solrRunMode` is `standalone`) | `shoreline` | `SOLR_CORE_NAME` |
| `solr.authentication.enabled` | Defines if the instance of Solr has Basic Authentication enabled | `true` | N/A |
| `solr.authentication.adminUsername` | Defines the admin username for Solr Basic Authentication (only set if `solr.authentication.enabled` is `true`) | `admin` | `SOLR_ADMIN_USER` |
| `solr.authentication.adminPassword` | Defines the admin password for Solr Basic Authenticaiton (only set if `solr.authentication.enabled` is `true`) | `admin` | `SOLR_ADMIN_PASSWORD` |

**SolrCloud vs. Standalone Solr**

You have the option to run an instance of Solr either as a part of the helm install or not managed by the chart (external). This is configured using the `solr.enabled` value.

When set to `true`, the Solr environment that comes with the chart is SolrCloud, and the chart will automatically set-up and configure the application to integrate with this instance.

When set to `false`, you have the option to run an instance of Solr using either SolrCloud or standalone. This is configured using the `starlight.solrRunMode` value. You also need to set additional values to configure the application to integrate with the external Solr instance (reference the solr parameters chart above).

Differences to note about SolrCloud and Standalone:
- Collections versus Cores
  - SolrCloud uses the concept of _collections_ whereas Standalone uses _cores_. This is why we have the two values `solr.collectionName` and `solr.coreName` - be sure to se these accordingly.
- Zookeeper
  - SolrCloud comprises a set of Solr nodes and Zookeeper nodes. If you are running Standalone Solr, zookeeper nodes are not present and those values are not needed.

**Solr Authentication**

If you are using an external Solr environment, you have the option to use or disable Basic Authentication for the appliation to access Solr. Be sure to set the `solr.authentication` appropriately.

#### Redis

See: https://github.com/helm/charts/blob/master/stable/redis/README.md

### Data Import and Export

The Starlight Helm chart contains optional configuration to enable the import
and/or export of data for a Helm chart deployment. Some use cases for this
functionality are:

Import:
* Migrating an existing non-k8s Starlight environment to a new Starlight
    environment managed by the Helm chart in k8s.
* Populating a local deployment with an export of an existing Starlight
    environment to explore the range of features. An example of this might be
    the Starlight documentation instance.
* Populating CI/CD Review applications with real data from an existing Starlight
    environment for review by Subject Matter Experts and other stakeholders.

Export:
* Nightly exports of the images and database for recovery. Note, this should not
    necessarily replace any backup strategy you would normally use for your
    applications.
* Export of a Starlight instance, such as the documentation site, for use in
    import use cases elsewhere, as noted above.

#### Import Configuration

| Parameter | Description | Default | Environment Variable |
| --------- | ----------- | ------- | -------------------- |
| `backups.import.enabled` | Enable the import Jobs during installation | `false` | N/A |
| `backups.import.accessKey` | S3/Minio access key | `nil` | `AWS_ACCESS_KEY_ID` |
| `backups.import.dbBackupSource` | s3:// URL or local file path for psql backup source file | `nil` | `DB_BACKUP_SOURCE` |
| `backups.import.dbBackupDestination` | s3:// URL or local file path for psql backup destination file | `nil` | `DB_BACKUP_DESTINATION` |
| `backups.import.endpointUrl` | S3/Minio endpoint URL | `nil` | `ENDPOINT_URL` |
| `backups.import.oldAppUrl` | URL for previous system, used for iiif url migration. e.g. `https://exhibits.ucsd.edu` | `nil` | `ENDPOINT_URL` |
| `backups.import.secretKey` | S3/Minio secret key | `nil` | `AWS_SECRET_ACCESS_KEY` |
| `backups.import.sourcePath` | s3:// URL or local directory path to images directory backup. Will be copied to `storage.bucket` | `nil` | `SOURCE_PATH` |

#### Export Configuration

| Parameter | Description | Default | Environment Variable |
| --------- | ----------- | ------- | -------------------- |
| `backups.export.enabled` | Enable the export Jobs during installation | `false` | N/A |
| `backups.export.accessKey` | S3/Minio access key | `nil` | `AWS_ACCESS_KEY_ID` |
| `backups.export.dbBackupSource` | s3:// URL or local file path for psql backup source file | `nil` | `DB_BACKUP_SOURCE` |
| `backups.export.dbBackupDestination` | s3:// URL or local file path for psql backup destination file | `nil` | `DB_BACKUP_DESTINATION` |
| `backups.export.destinationPath` | s3:// URL for images directory backups | `nil` | `DESTINATION_PATH` |
| `backups.export.endpointUrl` | S3/Minio endpoint URL | `nil` | `ENDPOINT_URL` |
| `backups.export.schedule` | k8s cron schedule for export. e.g: `30 8 * * *` | `nil` | N/A |
| `backups.export.secretKey` | S3/Minio secret key | `nil` | `AWS_SECRET_ACCESS_KEY` |
| `backups.export.sourcePath` | s3:// URL or local directory path to images directory in the currently deployed environment. Will be copied to `storage.bucket` | `nil` | `SOURCE_PATH` |

Note: If setting up an S3 bucket for import or export, which relies on the `sync` option
in the `aws-cli` tool, you will need to ensure that you set a `ListBucket`
statement as shown below:

```json
{
    "Version": "2012-10-17",
    "Id": "Policy1600725558503",
    "Statement": [
        {
            "Sid": "Stmt000001",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::111111111111:user/StarlightProdData"
            },
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::starlight-backup-test/*"
        },
        {
            "Sid": "Stmt000002",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::111111111111:user/StarlightProdData"
            },
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::starlight-backup-test"
        }
    ]
}
```

[starlight]:https://gitlab.com/surfliner/surfliner/-/tree/trunk/starlight
