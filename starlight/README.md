# Starlight

Starlight is based on Spotlight, a framework for the creation and presentation of
exhibits.

## Deploying Starlight

Please see our [Deploy](doc/deploy.md) documentation for details on how to
deploy a Starlight application to staging or production environments. For local
development and testing, please see [Developing Locally](README.md#developing-locally)

## Authentication

The environment variable `AUTH_METHOD` determines how users log in.  The options
are:

- `google`: Authenticates via Google OAuth
- `shibboleth`: Authenticates via Shibboleth
- `developer`: Authenticates via YAML file (for local testing only)
- `database`: Authenticates via standard Rails/Devise db-backed Users

### Authentication with Google

Users authenticate using Google.  To configure Starlight to connect to Google
using OAuth:

1. Create a new application at <https://console.developers.google.com/>.
1. Complete the OAuth consent form under the Credentials tab.
1. In the Credentials tab, select `Create credentials -> OAuth client ID`.  The
   type should be “Web application” and the Authoritized redirect URI should be
   your application’s hostname followed by `/users/auth/google_oauth2/callback`.
1. Set the environment variables `GOOGLE_AUTH_ID` and `GOOGLE_AUTH_SECRET` to
   the provided OAuth client ID and client secret, respectively.

## Importing Data

Images can be specified either via a url or via a filename. A CSV import file
must use either urls or files, not a mixture of both.  Files will be loaded
relative to an optional environment variable, `BINARY_ROOT`.

1. Create an exhibit. Ensure all the metadata fields you want are specified.
1. In the UI for your exhibit, go to Items --> Add Items --> Upload multiple items
1. Click `download template` to download a CSV template that contains all the metadata fields for your exhibit
1. Populate the CSV as appropriate. If you want to use local files instead of
urls, change the `url` column heading to say `file` instead.

    File paths will load relative to whatever value is set for
    `BINARY_ROOT`. e.g., if `BINARY_ROOT=/opt/ingest` and
    `file=images/sample.jpg` the file will load from
    `/opt/ingest/images/sample.jpg`.  If the file path starts with `/`, it will
    be treated as an absolute path and `BINARY_ROOT` will be ignored.
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

## Custom themes

Spotlight supports custom CSS themes for exhibits: <https://github.com/projectblacklight/spotlight/wiki/Creating-a-theme>

To add a custom theme to your Starlight installation, follow these steps:

1. Create `app/assets/stylesheets/application_theme-name.scss`, where
   `theme-name` is the name of your theme.
1. Create `app/views/shared/_header_navbar_theme-name.html.erb`, where
   `theme-name` is the name of your theme.
1. Create `app/views/shared/_footer_theme-name.html.erb`, where
   `theme-name` is the name of your theme.
1. Create a square PNG that identifies your theme at
   `app/assets/images/spotlight/themes/theme-name_preview.png`.
1. Add `theme-name` to the environment variable `SPOTLIGHT_THEMES`.
1. Add `application_theme-name.scss` to the
   `Rails.application.config.assets.precompile` array in
   `config/initializers/assets.rb`.
1. If you have any theme-specific image assets, create a subdirectory for them:
   `app/assets/images/themes/theme-name`.  Likewise for additional stylesheets:
   `app/assets/stylesheets/themes/theme-name`.

## Updating Universal Viewer

We are currently vendoring Universal Viewer and providing a symlink to the
`public/uv` directory to support cache invalidation when we update to a new
version. In order to update Universal Viewer to a newer version:
1. Update with yarn if you haven't already: `yarn install`
1. Update the vendored uv: `bin/uv-update`
1. Run tests to confirm things are still working
1. Commit and push your changes

## Developing locally

### Set up your local development instance
1. `git clone https://gitlab.com/surfliner/surfliner.git`
1. `cd surfliner/starlight`
1. `bundle install` to install gem dependencies
1. `rake db:migrate` to run database migrations
1. `yarn install` to install UniversalViewer
1. `solr_wrapper --config config/solr_wrapper_dev.yml` to spin up a local copy of solr for development
1. `rails s` to run rails server

To override environment variables set by `.env.development`, create a
`.env.development.local` file: <https://github.com/bkeepers/dotenv#what-other-env-files-can-i-use>

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

To teardown your environment:
1. `./bin/docker-teardown.sh -h` for options
1. `./bin/docker-teardown.sh -e test`  to teardown containers
1. `./bin/docker-teardown.sh -e test -v` to teardown containers AND volumes

### Set up a local admin account
1. Self-register in the web ui
1. Run this rake command: `rake spotlight:admin`
1. Enter the email address you registered when prompted

## Email settings
1. Set `ENV['FROM_EMAIL']` to whatever email address alert emails should come from.
