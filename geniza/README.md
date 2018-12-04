# Spotlight

Spotlight is a framework built on Blacklight that allows the creation
and presentation of exhibits.

This instance has been enhanced with a CLI batch import tool that
takes CSV metadata files and creates exhibits.

Additional metadata fields (beyond the defaults provided by Spotlight)
are set in `config/initializers/spotlight_initializer.rb`.

Which fields in your CSV file correspond to those are configued in
`config/import.yml` copy the `import.yml.template` file to
`import.yml` and set the appropriate values.  The `binary_root` key
assumes the `files` column in your metadata contains relative paths,
since a remote file share might be mounted in different places on
different systems.  The `exhibit_type_key` and `exhibit_class` keys
are used to identify which row of the CSV corresponds to the exhibit
metadata; by default, it looks for the row where the value for the
`type` column is `Collection`.

The CLI options are as follows:
```
Example:
      RAILS_ENV=development ./bin/import -m /data/mss292.csv
Usage:
      RAILS_ENV=[development|test|production] ./bin/ingest [options]
where [options] are:
  -d, --data=<s+>        Data file(s)/directory
  -m, --metadata=<s+>    Metadata file(s)/directory
  -v, --verbosity=<s>    Log verbosity: DEBUG, INFO, WARN, ERROR (default: INFO)
  -h, --help             Show this message
```

The `-d` flag is optional.  We have two indicators of where the
associated binary data will be: the 'files' attribute from the
metadata itself, and the set of paths passed using the `-d` flag with
the CLI.  If the path(s) specified in the metadata, when appended to
`binary_root`, yields an existent file, we use that.  Otherwise we'll
search through the paths given with `-d` in order to find a match.

## Developing locally

### Set up your local development instance
1. `git clone git@github.com:ucsblibrary/geniza.git`
1. `bundle install` to install gem dependencies
1. `rake db:migrate` to run database migrations
1. `solr_wrapper` to spin up a local copy of solr for development
1. `cp config/secrets.yml.template config/secrets.yml`
1. `cp config/import.yml.template config/import.yml`
1. `rails s` to run rails server

### Use database authentication instead of LDAP
If you want to use spotlight's built-in database authentication instead of LDAP,
either for local development or on a DCE server, set an environment variable in
.env.development or .env.production:
`DATABASE_AUTH=true`

### Set up a local admin account
1. Self-register in the web ui
1. Run this rake command: `rake spotlight:admin`
1. Enter the email address you registered when prompted

## Email settings
1. Set `Rails.application.secrets.email_from_address` to whatever email address alert emails should come from. Default value is 'noreply@library.ucsb.edu'.
