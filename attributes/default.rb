default['cog_security']['ssh_disable_root_login'] = false
default['cog_security']['sudo_group'] = 'sysadmin'
default['cog_security']['bucket_name'] = 'users'
default['cog_security']['home_base'] = '/home'
default['cog_security']['shell'] = '/bin/bash'
default['cog_security']['admin_users'] = []
default['cog_security']['users'] = []
default['cog_security']['remove_users'] = []
default['cog_security']['ssh_client_timeout'] = 1800

default['fail2ban']['bantime']  = 1800

default['authorization']['sudo']['groups']            = [default['cog_security']['sudo_group']]
default['authorization']['sudo']['users']             = []
default['authorization']['sudo']['passwordless']      = true
default['authorization']['sudo']['include_sudoers_d'] = false
default['authorization']['sudo']['agent_forwarding']  = false
default['authorization']['sudo']['sudoers_defaults']  = ['!lecture,tty_tickets,!fqdn']
default['authorization']['sudo']['command_aliases']   = []
default['authorization']['sudo']['env_keep_add']      = []
default['authorization']['sudo']['env_keep_subtract'] = []

case platform_family
when "debian"
  default['cog_security']['ssh_service_name'] = "ssh"
when "rhel"
  default['cog_security']['ssh_service_name'] = "sshd"
end

default['fail2ban']['services'] = {
  'ssh' => {
    "enabled" => "true",
    "port" => "ssh",
    "filter" => "sshd",
    "logpath" => '/var/log/messages',
    "maxretry" => "6"
  }
}
