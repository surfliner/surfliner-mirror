Message Queuing in Surfliner
============================

Many Surfliner products optionally publish and/or subscribe messages to a
queuing backend powered by [RabbitMQ](https://www.rabbitmq.com/).

These documents pertain to the maintenance of that queuing system, and the
inter-product issues related to publishing to, and consuming messages from the
queue. For information about how to configure each product to talk to the
queuing backend, check the individual project's documentation.

## Topics

### Architecture
Currently, the primary intelligence responsible for creating the message bus
resides in two files.

 - ci/base/rabbitmq_operator.yml
 - ci/base/rabbitmq_cluster.yml

These two files are referenced in ci/base/base.yaml which is included in
.gitlab-ci.yml.  The configuration is fairly straight forward, but one section
bears some explanation.

    .rabbitmq-rules-default-branch:
	   rules:
	     - if: '$CI_COMMIT_BRANCH  ==  $CI_DEFAULT_BRANCH'
	       changes:
	         - ci/base/rabbitmq_operator.yml
	     - if: $DEPLOY_RABBITMQ_OPERATOR && '$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH'

Because of these lines, which occur in both the operator and cluster yaml files,
it is possible to force a rabbitmq deploy to occur even if no changes have taken
place in the rabbitmq .yml files.  This isolates the deployment of the operator
and cluster from deployment of the various pieces of Surfliner but still
provides flexibility during development when a queue is needed but not
necessarily part of the current build changes.  Setting either the
`DEPLOY_RABBITMQ_CLUSTER`or `DEPLOY_RABBITMQ_OPERATOR` environment variables
will force a deploy of that element in any default branch merge pipeline.

The basics of how a rabbitmq operator works and it's architecture are documented
here: https://www.rabbitmq.com/kubernetes/operator/operator-overview.html

There are also documents on how to override defaults using templating here:
https://www.rabbitmq.com/kubernetes/operator/configure-operator-defaults.html

### Operational considerations
It is often necessary to inspect the condition of the message queue(s) in order
to debug processes.  The easiest way to do this is with a kubectl port forward
of the web ui that comes with rabbitmq.  The following is a quick example.

	$ kubectl --kubeconfig prod.yaml get namespaces rabbitmq-prod
	Active   8d rabbitmq-staging              Active   8d rabbitmq-system
	Active   22d $ kubectl --kubeconfig prod.yaml get pods -n rabbitmq-staging
	NAME                                READY   STATUS    RESTARTS   AGE
	surfliner-rabbitmq-stage-server-0   1/1     Running   0          8d $
	kubectl --kubeconfig prod.yaml port-forward surfliner-rabbitmq-stage-server-0 15672:15672 -n rabbitmq-staging

You should then be able to connect to localhost:15672 in a web browser and use
the UI to debug or manipulate the message queue on that pod.

### `surfliner.metadata`

Messages related to events impacting metadata are published on this topic.
