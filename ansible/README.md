# Provisioning servers

1. `ansible-galaxy install --roles-path roles -r roles/requirements.yml`
1. `cp inventory.template inventory`
1. Edit `inventory` and set `ansible_ssh_host` to the server you’re deploying
   to.
1. Set `ansible_ssh_user` to the user that Ansible should SSH as.

## Starlight

1. Create a vars file for any site-specific variables you need (see
   `spotlight.yml` for unset variables).  For example:
    ```yaml
    ---
    db_pass: 'real-good-password'
    fqdn: spotlight-prod.campus.edu
    smtp_host: smtp.campus.edu
    ```
1. Uncomment and/or add any additional roles you need (e.g., `fstab` and `environment-variables`).
1. Run the playbook: `ansible-playbook -i inventory -e @vars/local.yml spotlight.yml`
