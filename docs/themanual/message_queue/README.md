Message Queuing in Surfliner
============================

Many Surfliner products optionally publish and/or subscribe messages to a
queuing backend powered by [RabbitMQ](https://www.rabbitmq.com/).

These documents pertain to the maintenance of that queuing system, and the
inter-product issues related to publishing to, and consuming messages from,
the queue. For information about how to configure each product to talk to
the queuing backend, check the individual project's documentation.

## Topics

### `surfliner.metadata`

Messages related to events impacting metadata are published on this topic.
