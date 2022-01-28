# Configuring Tidewater

## OAI‐PMH Configuration

The OAI‐PMH provider can be configured via the following environment
  variables&#x202F;:—

<dl>
  <dt><code>OAI_ADMIN_EMAIL</code></dt>
  <dd>

The administrator email which should appear in an OAI‐PMH `Identify`
  response.

  </dd>
  <dt><code>OAI_NAMESPACE_IDENTIFIER</code></dt>
  <dd>

The `namespace-identifier` component described in
  [the OAI identifier format specification][if].
This **should** be a domain name under your control (and not used by
  any other OAI‐PMH providers).

  </dd>
  <dt><code>OAI_REPOSITORY_NAME</code></dt>
  <dd>

A human‐readible name for the OAI repository, as it should appear in an
  OAI‐PMH `Identify` response.

  </dd>
  <dt><code>OAI_REPOSITORY_ORIGIN</code></dt>
  <dd>

The origin for the OAI‐PMH endpoint, as it should appear in an OAI‐PMH
  `Identify` response.

  </dd>
  <dt><code>OAI_SAMPLE_ID</code></dt>
  <dd>

A sample `local-identifier` component as described in
  [the OAI identifier format specification][if].
This **should** match the format of the `id` column in the `oai_items`
  table of the database.

  </dd>
</dl>

[if]: http://www.openarchives.org/OAI/2.0/guidelines-oai-identifier.htm

## Database Configuration

Tidewater expects a Postgres database configured according to the
  `POSTGRES_*` environment variables (see `.env`).
