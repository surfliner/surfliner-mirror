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

Images must be specified via a url.

1. Create an exhibit. Ensure all the metadata fields you want are specified.
1. In the UI for your exhibit, go to Items --> Add Items --> Upload multiple items
1. Click `download template` to download a CSV template that contains all the metadata fields for your exhibit
1. Populate the CSV as appropriate.
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
1. Update with yarn if you haven't already: `yarn upgrade`
1. Update the vendored uv: `bin/uv-update`
1. Run tests to confirm things are still working
1. Commit and push your changes

## Developing locally

You will need Docker and Docker Compose installed on your host/local system.

To setup a development environment:
1. `docker-compose build` to build images (`docker-compose up --build` does not work)
1. `docker-compose up`  to run dev environment
1. Access the application on http://localhost:3000

For running tests:
```
docker-compose exec web sh -c 'RAILS_QUEUE=inline RAILS_ENV=test bundle exec rake'
```

See the [`docker-compose` CLI
reference](https://docs.docker.com/compose/reference/overview/) for more on commands.

#### Persisting Data during Docker development
The docker entrypoint script will read an environment variable named
`DATABASE_COMMAND` that allows you to determine what database rake commands are
run when the container is started.

By default in `.env.docker` and `.env.docker.test` this will run `db:create
db:schema:load`. This is desirable because if someone is developing locally
without docker they are likely using `sqlite3` whereas if someone is using
docker they will be using `postgres`. So any `db:migrate` commands will
potentially generate conflicts. However, it means that each `up` command will
wipe any existing data, which may be problematic during development.

If you wish to persist data across sessions, after the initial creation of the
containers, you can simply comment out or remove the `DATABASE_COMMAND`, to
ensure it does not run `db:schema:load` in future runs.

### Load sample data and admin account
You can use the [sample rake file](lib/tasks/sample.rake) to load a sample
exhibit and generate an administrative user.  The admin user has the email
address `admin@localhost` and the password `testing`.  This user and exhibit
will exist on review deployments in GitLab.

```
docker-compose exec web bundle exec rake starlight:seed_admin_user
docker-compose exec web bundle exec rake starlight:sample:seed_exhibit
```

### Set up a local admin account
1. Self-register in the web ui
1. Run this rake command: `rake spotlight:admin`
1. Enter the email address you registered when prompted

## Email settings
1. Set `ENV['FROM_EMAIL']` to whatever email address alert emails should come from.
