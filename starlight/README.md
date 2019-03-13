# Starlight

Starlight is baed on Spotlight, a framework for the creation and presentation of
exhibits.

## Importing Data

Images can be specified either via a url or via a filename. A CSV import file
must use either urls or files, not a mixture of both.  Files will be loaded
relative to an optional environment variable, `BINARY_ROOT`.

1. Create an exhibit. Ensure all the metadata fields you want are specified.
1. In the UI for your exhibit, go to Items --> Add Items --> Upload multiple items
1. Click `download template` to download a CSV template that contains all the metadata fields for your exhibit
1. Populate the CSV as appropriate. If you want to use local files instead of urls, change the `url` column heading to say `file` instead. File paths will load relative to whatever value is set for `BINARY_ROOT`. e.g., if `BINARY_ROOT=/opt/ingest` and `file=images/sample.jpg` the file will load from `/opt/ingest/images/sample.jpg`
1. Click `choose file` and upload your populated CSV file.

## Google Analytics

Starlight supports using Google Analytics for your exhibits. To prepare your
application for leveraging analytics, you will need to create a Project
following the [instructions provided by Google.](https://developers.google.com/api-client-library/ruby/start/get_started)

You will need to provide the information/configuration properties you receive as
part of the Project setup process as environment variables described below:

- `GA_PKCS12_KEY_PATH` - full path to your private key
- `GA_WEB_PROPERTY_ID` - typically of the form `UA-99999999-1`
- `GA_EMAIL` - email address/service account ID associated with the account

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

### With Docker

You will need Docker and Docker Compose installed on your host/local system.

There are two docker-compose files, which allow you to run development and test
instances of the application if you would like.

To setup a development environment:
1. `git clone https://gitlab.com/surfliner/surfliner.git`
1. `cd surfliner/starlight`
1. `./bin/docker-build.sh`  to build images
1. `./bin/docker-up.sh`  to run dev environment
   run database migrations
1. Browse to http://localhost:3000

For running tests:
1. `./bin/docker-build.sh -e test`  to build images
1. `./bin/docker-up.sh -e test`  to run dev environment
1. `./bin/docker-spec.sh -e test` to run test suite

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
