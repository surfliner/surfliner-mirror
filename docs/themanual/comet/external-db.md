## Configuring Comet to use an external PostgreSQL database

Having the database separate from the application deployment will make future
upgrades and migrations easier.

### Deploy the standalone DB

Create and install a secrets file manually, with the following fields:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: comet-staging-postgres
  namespace: postgresql-staging
type: Opaque
data:
  postgresql-postgres-password: "<b64enc>"
  postgresql-password: "<b64enc>"
```

Then configure the rest of the DB settings
```yaml
image:
  repository: bitnami/postgresql
  tag: 12.7.0
cpu: 1000m
memory: 1Gi
postgresqlUsername: comet
postgresqlDatabase: comet-staging
existingSecret: comet-staging-postgres
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

### Teaching Comet how to connect to the external DB

In the Comet namespace, create a secret file with the database credentials as
environment variables:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: comet-postgres
  namespace: comet-staging
type: Opaque
data:
  DB_PASSWORD: "<b64enc>"
  DB_HOST: "<b64enc>"
  DB_USERNAME: "<b64enc>"
  DATABASE_URL: "<b64enc>"
  PGDATABASE: "<b64enc>"
```

In the `values.yaml` for your Comet deployment, configure the external DB:
```yaml
postgresql:
  enabled: false

externalPostgresql:
  database: comet-staging
  host: comet-staging-postgresql.postgresql-staging
  username: comet

extraEnvFrom:
  - secretRef:
      name: comet-postgres
worker:
  extraEnvFrom:
    - secretRef:
        name: comet-postgres
```

See the [UCSB staging
configuration](https://gitlab.com/surfliner/surfliner/-/blob/trunk/charts/snippets/comet/ucsb-staging-deploy.yaml)
for an example.

Then deploy, with an additional `--set` flag to pass the secret file to the
`ensure-metadata-db-exists` initContainer:

```
helm upgrade --install \
    -n comet-staging \
    surfliner-comet-stage \
    charts/hyrax \
    --set extraInitContainers[0].envFrom[0].configMapRef.name=surfliner-comet-stage-hyrax-env \
    --set extraInitContainers[1].envFrom[0].configMapRef.name=surfliner-comet-stage-hyrax-env \
    --set extraInitContainers[1].envFrom[1].secretRef.name=surfliner-comet-stage-hyrax \
    --set extraInitContainers[1].envFrom[2].secretRef.name=comet-postgres \
    --values charts/snippets/comet/init-containers.yaml \
    --values charts/snippets/comet/staging-deploy.yaml \
    --values charts/snippets/comet/ucsb-solr-staging.yaml \
    -f charts/snippets/comet/ucsb-staging-deploy.yaml
```

See? Easy 😄
