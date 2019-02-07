# Starlight

Starlight is baed on Spotlight, a framework for the creation and presentation of
exhibits.

## Importing Data

### Via the UI
The preferred way to import data into Starlight is via the UI. Images can be specified
either via a url or via a filename. A CSV import file must use either urls or files, not a mixture of both.
Files will be loaded relative to an optional environment variable, IMPORT_DIR.

1. Create an exhibit. Ensure all the metadata fields you want are specified.
1. In the UI for your exhibit, go to Items --> Add Items --> Upload multiple items
1. Click `download template` to download a CSV template that contains all the metadata fields for your exhibit
1. Populate the CSV as appropriate. If you want to use local files instead of urls, change the `url` column heading to say `file` instead. File paths will load relative to whatever value is set for IMPORT_DIR. e.g., if `IMPORT_DIR=/opt/ingest` and `file=images/sample.jpg` the file will load from `/opt/ingest/images/sample.jpg`
1. Click `choose file` and upload your populated CSV file.

### Via the command line
**Note:** The command line import is not being actively developed and should not
be used without consultation with the Starlight development team.

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
1. `git clone https://gitlab.com/surfliner/surfliner.git`
1. `cd surfliner/starlight`
1. `bundle install` to install gem dependencies
1. `rake db:migrate` to run database migrations
1. `yarn install` to install UniversalViewer
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
