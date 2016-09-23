# cog_security-cookbook

This cookbook implements security policies for Cash on Go.

## Supported Platforms

Amazon Linux, CentOS and Debian

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
    <td><tt>'sysadmin'</tt></td>
  </tr>
  <tr>
    <td><tt>['cog_security']['admin_users']</tt></td>
    <td>Array</td>
    <td>Array of admin usernames</td>
    <td><tt>[]</tt></td>
  </tr>
  <tr>
    <td><tt>['cog_security']['users']</tt></td>
    <td>Array</td>
    <td>Array of usernames without sudo rights</td>
    <td><tt>[]</tt></td>
  </tr>
  <tr>
    <td><tt>['cog_security']['remove_users']</tt></td>
    <td>Array</td>
    <td>Array usernames to be removed</td>
    <td><tt>[]</tt></td>
  </tr>
  <tr>
    <td><tt>['cog_security']['bucket_name']</tt></td>
    <td>String</td>
    <td>second part of vault name (item), first part is fixed to 'cog_security'</td>
    <td><tt>'users'</tt></td>
  </tr>
  <tr>
    <td><tt>['cog_security']['ssh_client_timeout']</tt></td>
    <td>Integer</td>
    <td>timeout before logging out inactive user</td>
    <td><tt>'users'</tt></td>
  </tr>
  <tr>
    <td><tt>['cog_security']['slack_webhook']</tt></td>
    <td>String</td>
    <td>Slack channel to send fail2ban notices</td>
    <td><tt>'#test'</tt></td>
  </tr>
  <tr>
    <td><tt>['fail2ban']['bantime']</tt></td>
    <td>Integer</td>
    <td>How many seconds IP address will be locked out</td>
    <td><tt>1800</tt></td>
  </tr>
  <tr>
    <td><tt>['fail2ban']['email]</tt></td>
    <td>String</td>
    <td>E-mail address where to send Fail2ban reports
    <td><tt>admin@cashongo.co.uk</tt></td>
  </tr>
  <tr>
    <td><tt>['fail2ban']['services']['ssh']['enabled']</tt></td>
    <td>String</td>
    <td>String ("true"|"false") to notify if ssh check on fail2ban is enabled or disabled</td>
    <td><tt>'true'</tt></td>
  </tr>

</table>

This is how you define attributes in environment:

```ruby
name "intra-prod"
description "Internal production environment"
default_attributes(
  cog_security: {
    slack_channel: '#alarms-security',
    bucket_name: 'intra-prod',
    admin_users: ['sysadmin.l','sysadmin.a','sysadmin.j'],
    users: ['user.a','user.b'],
    remove_users: ['user.x','user.y']
  }
)

```
## Usage

### cog_security::default

It needs two things to work: attributes (which specify users and vault name) and
vault where users are.

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

Create knife vault for your entity, vault name should be

    ['cog_security'][node['cog_security']['bucket_name']]

```json
{
  "slack_webhook": "http://slackwebhookurl/",
  "sysadmin.user.a": {
    "ssh_keys": [
      "ssh-rsa AAAA....xxx user@machine"
    ],
    "shell": "/bin/bash",
    "comment": "Sysadmin User A"
  },
  "sysadmin.user.b": {
    "ssh_keys": [
      "ssh-rsa BBBB....xxx userb@machine"
    ],
    "comment": "Sysadmin User B"
  }
}
```

There can be more then 1 ssh-key (it is an array).

If item named "root" exists in data bag and there is password hash, it will update
root password, root user does not have to be in admin_users array.

Removing users will break if user process is running.

This cookbook uses `fail2ban` cookbook which can be managed by node attributes.
Some attributes are already defined, but those attributes can be overrided.

Look at fail2ban cookbook documentation at http://supermarket.chef.io

## License and Authors

Author:: Lauri Jesmin (<lauri.jesmin@cashongo.co.uk>)
