# solrconf

This gem provides rake tasks for configuring Solr instances.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'solrconf'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install solrconf

## Usage

The `upload` task uploads Solr configuration files (schema, etc) to ZooKeeper as
a global configset named `solrconfig`:

```sh
export ZK_HOST=localhost
export ZK_PORT=2181
rake solrconf:upload[path/to/configfiles]
```
