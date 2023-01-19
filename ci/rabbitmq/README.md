To support deployment of the operator via helm chart, the authentication for the admin user needs to be in a secret in the following format on the target namespace for the operator.

    apiVersion: v1
    kind: Secret
    type: Opaque
    metadata:
    name: rabbitmq-credentials
    data:
    RABBITMQ_DEFAULT_USER: "c3VyZmxpbmVy"
    RABBITMQ_DEFAULT_PASS: "c3VyZmxpbmVy"

To allow for customizing the username and password of the clusters that are created by the operator, a secret of the following format needs to exist on the target namespace for the cluster.

    kind: Secret
    apiVersion: v1
    metadata:
    name: surfliner-rabbitmq-prod-default-user
    namespace: rabbitmq-prod
    stringData:
    default_user.conf: |
        default_user = surfliner
        default_pass = surfliner
    password: surfliner
    username: surfliner