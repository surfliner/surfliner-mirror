# Migrating a Starlight instance

The upstream Spotlight import/export functionality is imperfect, so we’ve
developed our own tooling for migrating all content from one Starlight instance
to another.

## Export PostgreSQL database

Create a DB dump from the source database.  Ideally, **the version of `pg_dump`
should match the version of the new, target database,** rather than the source:

```
pg_dump -Fc "${DATABASE_URL}" > spotight-export.datetime.dump
```

## Export uploaded content

```shell
tar cvf ~/uploads.tar /path/to/public/uploads/ # then scp etc to a local machine
```

## Create S3 buckets

Create two S3 buckets, one for holding temporary migration objects, the other
for the new Starlight instance to use as its permanent storage for uploaded
content.  Copy the DB dump and the (unzipped) `uploads` directory to the
migration bucket.

## Deploy standalone PostgreSQL instance (optional but recommended)

Having the database separate from the application deployment will make future
upgrades and migrations easier.

Create and install a secrets file manually, with the following fields:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: starlight-staging-postgres
  namespace: postgresql-staging
type: Opaque
data:
  postgresql-postgres-password: "<b64enc>"
  postgresql-password: "<b64enc>"
```

Then use it to deploy a database:
```yaml
image:
  repository: bitnami/postgresql
  tag: 12.7.0
cpu: 1000m
memory: 1Gi
postgresqlUsername: starlight
postgresqlDatabase: starlight-staging
existingSecret: starlight-staging-postgres
servicePort: 5432
persistence:
  size: 10Gi
```

If you don’t have the Bitnami chart repository, add it:
```
helm repo add bitnami https://charts.bitnami.com/bitnami
```

Then install PostgreSQL with Helm:
```
helm install -n postgresql-staging starlight-staging bitnami/postgresql -f path/to/config.yaml
```

## Deploy new Starlight instance

As with the PostgreSQL deployment, pre-create a secrets file for the deployment:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: starlight
  namespace: starlight-staging
type: Opaque
data:
  AWS_SECRET_ACCESS_KEY: "<b64enc>"
  GOOGLE_AUTH_ID: "<b64enc>"
  GOOGLE_AUTH_SECRET: "<b64enc>"
  POSTGRES_ADMIN_PASSWORD: "<b64enc>"
  POSTGRES_PASSWORD: "<b64enc>"
  POSTGRES_USER: "<b64enc>"
  SECRET_KEY_BASE: "<b64enc>"
  SMTP_PASSWORD: "<b64enc>"
```

As you might guess from the presence of a single AWS key, the two buckets we
created must both be accessible by the same user.

Then create a custom values YAML file for the new deployment.  See the [UCSB
staging
configuation](https://gitlab.com/surfliner/surfliner/-/blob/trunk/charts/snippets/starlight/staging/ucsb.yaml)
as an example.

Ensure the chart dependencies are up to date (`helm dep update
charts/starlight`), then install and hope for the best:
```
helm install -n starlight-staging surfliner-starlight-stage charts/starlight -f path/to/custom/values.yaml
```
