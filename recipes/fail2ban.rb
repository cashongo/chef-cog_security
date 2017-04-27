chef_gem 'chef-vault' do
  compile_time true if respond_to?(:compile_time)
end

require 'chef-vault'

userdata = ChefVault::Item.load('cog_security',node['cog_security']['bucket_name'])
Chef::Log.info(userdata.inspect)
package 'curl'

directory '/etc/fail2ban/action.d' do
  owner 'root'
  group 'root'
  mode 00755
  recursive true
  action :create
end

template '/etc/fail2ban/slack_notify.sh' do
  source 'slack_notify.sh.erb'
  owner 'root'
  group 'root'
  mode 0755
  variables(
    hook: userdata['slack_webhook'],
    hostname: node.has_key?('set_fqdn') ? node['set_fqdn'] : node['fqdn'],
    channel: node['cog_security']['slack_channel']
  )
  sensitive true
end

cookbook_file '/etc/fail2ban/action.d/slack.conf' do
  source 'slack.conf'
  owner 'root'
  group 'root'
  mode 00644
end

include_recipe 'fail2ban'
