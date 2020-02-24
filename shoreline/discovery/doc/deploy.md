# Deploying Shoreline

## Environment Variables

Shoreline aims at following the [12 factor application][12-factor] pattern as
much as possible. To that end, there are a set of environment variables that one
should populate when deploying to a staging/production server. Development and
test instances have sane defaults that you should not need to adjust unless you
want to.

How you make these environment variables available during deployment and
application runtime is up to you. You could use an Ansible playbook, Chef,
Puppet, or whatever works best in your local environment and practices.

### Runtime Variables

| Name | Description | Required |
| ---- | ----------- | -------- |
| `SHORELINE_THEME` | Custom theme (CSS, header, footer) to be activated (e.g., `ucsb`) | No |

[12-factor]: https://12factor.net/
