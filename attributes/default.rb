default['cog_security']['ssh_disable_root_login'] = false
default['cog_security']['sudo_group'] = 'sysadmin'
default['cog_security']['bucket_name'] = 'users'
default['cog_security']['home_base'] = '/home'
default['cog_security']['shell'] = '/bin/bash'
default['cog_security']['admin_users'] = []
default['cog_security']['users'] = []
default['cog_security']['remove_users'] = []
default['cog_security']['ssh_client_timeout'] = 1800
default['cog_security']['ssh_client_timeout_count_max'] = 0
default['cog_security']['slack_channel'] = '#test'

default['fail2ban']['bantime']  = 1800
default['fail2ban']['email'] = 'admin@cashongo.co.uk'
default['fail2ban']['logtarget'] = 'SYSLOG'

default['fail2ban']['syslog_facility'] = 'daemon'
default['fail2ban']['syslog_target'] = '/dev/log'

default['fail2ban']['banaction'] = 'firewallcmd-new' if (platform_family = 'rhel' &&  platform_version[0,1]=='7')

default['authorization']['sudo']['groups']            = [default['cog_security']['sudo_group']]
default['authorization']['sudo']['users']             = []
default['authorization']['sudo']['passwordless']      = true
default['authorization']['sudo']['include_sudoers_d'] = false
default['authorization']['sudo']['agent_forwarding']  = false
default['authorization']['sudo']['sudoers_defaults']  = ['!lecture,tty_tickets,!fqdn']
default['authorization']['sudo']['command_aliases']   = []
default['authorization']['sudo']['env_keep_add']      = []
default['authorization']['sudo']['env_keep_subtract'] = []

case node.platform_family
when 'debian'
  default['cog_security']['ssh_service_name'] = 'ssh'
  default['cog_security']['log_file'] = '/var/log/auth.log'
when 'rhel'
  default['cog_security']['ssh_service_name'] = 'sshd'
  default['cog_security']['log_file'] = '/var/log/messages'
end



default['fail2ban']['services'] = {
  ssh: {
    enabled: 'true',
    port: 'ssh',
    filter: 'sshd',
    logpath: default['cog_security']['log_file'],
    action: '%(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
                 slack[name=%(__name__)s]',
    maxretry: '6'
  },
  'ssh-iptables' => {
    enabled: 'false',
    port: 'ssh',
    filter: 'sshd',
    logpath: default['cog_security']['log_file'],
    maxretry: 6
  }
}
