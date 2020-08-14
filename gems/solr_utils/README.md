# solr_utils

This gem provides rake tasks for configuring Solr instances.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "solr_utils", path: "../gems/solr_utils"
```

And then execute:

    $ bundle install

## Usage

### `upload`

The `upload` task uploads Solr configuration files (schema, etc) to ZooKeeper as
a global configset named `solr_utilsig`:

```sh
export ZK_HOST=localhost
export ZK_PORT=2181
rake solr_utils:upload[path/to/configfiles]
```

### `delete_by_ids`

This task deletes Solr documents by ID:
```sh
export SOLR_DELETE_IDS=FY2015_ADDRESS_POINT,citiescounty_021616
rake solr_utils:delete_by_ids
```
