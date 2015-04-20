# cog_security-cookbook

This cookbook
## Supported Platforms

Linux, centos and debian

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['cog_security']['ssh_disable_root_login']</tt></td>
    <td>Boolean</td>
    <td>Disable ssh root login </td>
    <td><tt>false</tt></td>
  </tr>
  <tr>
    <td><tt>['cog_security']['sudo_group']</tt></td>
    <td>String</td>
    <td>Sudo group name</td>
    <td><tt>'wheel'</tt></td>
  </tr>
  <tr>
    <td><tt>['cog_security']['admin_users']</tt></td>
    <td>Array</td>
    <td>Array of admin usernames</td>
    <td><tt>[]</tt></td>
  </tr>
  <tr>
    <td><tt>['cog_security']['bag_name']</tt></td>
    <td>String</td>
    <td>Data bag name</td>
    <td><tt>'users'</tt></td>
  </tr>
</table>

## Usage

### cog_security::default

Include `cog_security` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[cog_security::default]"
  ]
}
```
Attribute ['cog_security']['admin_users'] should contain array of users who 
will be added and put into group which will have sudo rights without password.

Except root, no user will get password, only SSH keys. 

Root user is for console, other users are for SSH remote access.

Create knife vault for each user, bag name should be ['cog_security']['bag_name'],
item name should be username

```json
{
  "id": "sysadmin.user",
  "ssh_keys": [
    "ssh-rsa AAAA....xxx user@machine"
    ],
  "shell": "/bin/bash",
  "comment": "Sysadmin User"
}
```

There can be more then 1 ssh-key (it is an array).

If item named "root" exists in data bag and there is password hash, it will update
root password, root user does not have to be in admin_users array.

## License and Authors

Author:: Lauri Jesmin (<lauri.jesmin@cashongo.co.uk>)
