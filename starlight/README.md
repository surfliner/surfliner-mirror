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

The current practice for Starlight development is to use a `k3s` tool called `k3d`
which creates containerized `k3s` clusters.

You will need the following tools installed on your local machine:

* [Docker][docker]
* [kubectl][kubectl]
* [Helm][helm]
* [k3d][k3d]

Additionally, you will want some way of monitoring and managing the application
deployments into the `k3s` cluster. There are a variety of tools for doing this:

* [k9s][k9s] - A terminal-based tool for managing k8s clusters
* [Rancher][rancher] - Provides a very nice UI, but a heavier weight
    installation locally.
* Using `kubectl` and `helm` directly. There are times where this is best, but
    is likely a last resort for regular monitoring.

There are likely other tools in this space as well. As of this writing our team
currently has experience with both `k9s` and `Rancher`, so these are currently
recommended.

In general, it is advisable to keep all of these tools up to date. The
Kubernetes development space and related tooling moves quickly.

### Provisioning the development environment

1. `make setup` (create the K8s cluster, namespace, etc. if needed)
1. `make build` (create the Starlight Docker image and push it to the local k3d
   registry)
1. `make deploy` (deploy Starlight to the local k3d cluster)

The application will be available, by default, at:

```sh
http://starlight.k3d.localhost
```

And the Minio/S3 UI is available at:

```sh
http://starlight-minio.k3d.localhost
```

#### Customizing Helm Values in Deployment
It may be the case that one needs to specify difference Helm values than are
used by the default `k3d.yaml` file. To do this:

- Create an additional `yaml` file with the values you need to update or change
- Export an environment variable name `LOCAL_VALUES_FILE` and set the value to
    the path to your `yaml` file
- Run `make deploy`

Example:

With a `yaml` file stored in `/tmp/local-starlight-values.yaml`

```yaml
ingress:
  enabled: true
  hosts:
    - host: 'starlight.k3d.my-server'
      paths: ['/']
```

```sh
export LOCAL_VALUES_FILE="/tmp/local-starlight-values.yaml"
make deploy
```

### Set up a local admin account
1. Self-register in the web ui
1. Run this rake command: `rake spotlight:admin`
1. Enter the email address you registered when prompted

## Email settings
1. Set `ENV['FROM_EMAIL']` to whatever email address alert emails should come from.

[docker]: https://docs.docker.com/engine/install/
[helm]: https://helm.sh/docs/intro/install/
[hyrax]: https://hyrax.samvera.org/
[k3d]: https://github.com/rancher/k3d/#get
[k9s]: https://github.com/derailed/k9s
[kubectl]: https://kubernetes.io/docs/tasks/tools/
[rancher]: https://rancher.com/docs/rancher/v2.5/en/installation/install-rancher-on-k8s/
[samvera]: https://samvera.org/
