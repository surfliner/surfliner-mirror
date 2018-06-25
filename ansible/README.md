# Running

Edit `inventory` and set `ansible_ssh_host` to your domain.

```shell
ansible-galaxy install --roles-path roles -r roles/requirements.yml
ansible-playbook -i inventory vivolight.yml
```
