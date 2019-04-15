# Provisioning servers with Ansible Galaxy

* We use [Ansible Galaxy](https://galaxy.ansible.com/) for provisioning infrastructure and deploying starlight. 
* Galaxy provides a hub of pre-packaged units of work known to Ansible as roles that can be found, reused and shared as needed. 
* Roles can be dropped into Ansible PlayBooks and immediately put to work. 
* `ansible-galaxy` is the command line tool that comes bundled with Ansible.

1. `ansible-galaxy install --roles-path roles -r roles/requirements.yml`
2. `cp inventory.template inventory`
3. Edit `inventory` and set `ansible_ssh_host` to the server you’re deploying
   to.
4. Set `ansible_ssh_user` to the user that Ansible should SSH as.

## Starlight

1. Create a vars file for any site-specific variables you need (see
   `spotlight.yml` for unset variables).  For example:
    ```yaml
    ---
    db_pass: 'real-good-password'
    fqdn: spotlight-prod.campus.edu
    smtp_host: smtp.campus.edu
    proxy: 'http://10.3.100.201:3128'
    ```
2. Uncomment and/or add any additional roles you need (e.g., `fstab` and `environment-variables`).
3. Run the playbook: `ansible-playbook -i inventory -e @vars/local.yml spotlight.yml`
