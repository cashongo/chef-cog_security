#
# Cookbook Name:: cog_security
# Recipe:: default
#
# Copyright (C) 2015 Lauri Jesmin
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'sudo'
include_recipe 'fail2ban'

service "ssh" do
  service_name node['cog_security']['ssh_service_name']
  action :nothing
end

chef_gem 'chef-vault' do
  compile_time true if respond_to?(:compile_time)
end

require 'chef-vault'

userdata = ChefVault::Item.load('cog_security',node['cog_security']['bucket_name'])

if !userdata['root'].nil? && !userdata['root']['password'].nil? then
  user 'root' do
    action :manage
    password userdata['root']['password']
  end
end

allusers = node['cog_security']['admin_users'] + node['cog_security']['users']

allusers.each do |n|
  ### Need to create user first
  home_dir=node['cog_security']['home_base'] + '/' + n
  user n do
    action :create
    home home_dir
    manage_home true
    comment userdata[n]['comment'] || ''
    shell userdata[n]['shell'] || node['cog_security']['shell']
    notifies :reload, "ohai[reload_passwd]", :immediately
  end

  directory "#{home_dir}/.ssh" do
    owner n
    group lazy { node['etc']['passwd'][n]['gid'] }
    mode "0700"
  end

  template "#{home_dir}/.ssh/authorized_keys" do
    source "authorized_keys.erb"
    cookbook 'cog_security'
    owner n
    group lazy { node['etc']['passwd'][n]['gid'] }
    mode "0600"
    variables :ssh_keys => userdata[n]['ssh_keys']
    only_if {userdata[n]['ssh_keys']}
  end
end

node['cog_security']['remove_users'].each do |n|
  user n do
    action :remove
    manage_home true
  end
end

ruby_block "edit sshd_config disable root login" do
  block do
    rc = Chef::Util::FileEdit.new("/etc/ssh/sshd_config")
    rc.insert_line_if_no_match(/^PermitRootLogin/, "PermitRootLogin " + (node['cog_security']['ssh_disable_root_login'] ? 'no' : 'yes'))
    rc.search_file_replace_line(/^PermitRootLogin/,"PermitRootLogin " + (node['cog_security']['ssh_disable_root_login'] ? 'no' : 'yes'))
    rc.write_file
  end
  notifies :reload, "service[ssh]"
end

ruby_block "edit sshd_config set client timeout" do
  only_if { node['cog_security'].has_key?('ssh_client_timeout') && node['cog_security']['ssh_client_timeout'] > 0 }
  block do
    rc = Chef::Util::FileEdit.new("/etc/ssh/sshd_config")
    rc.insert_line_if_no_match(/^ClientAliveInterval/, "ClientAliveInterval #{node['cog_security']['ssh_client_timeout']}")
    rc.search_file_replace_line(/^ClientAliveInterval/,"ClientAliveInterval #{node['cog_security']['ssh_client_timeout']}")
    rc.write_file
  end
  notifies :reload, "service[ssh]"
end

ruby_block "edit sshd_config set client alive count max" do
  only_if { node['cog_security'].has_key?('ssh_client_timeout') && node['cog_security']['ssh_client_timeout'] > 0 }
  block do
    rc = Chef::Util::FileEdit.new("/etc/ssh/sshd_config")
    rc.insert_line_if_no_match(/^ClientAliveCountMax/, "ClientAliveCountMax #{node['cog_security']['ssh_client_timeout_count_max']}")
    rc.search_file_replace_line(/^ClientAliveCountMax/,"ClientAliveCountMax #{node['cog_security']['ssh_client_timeout_count_max']}")
    rc.write_file
  end
  notifies :reload, "service[ssh]"
end


group node['cog_security']['sudo_group'] do
  action :create
  members node['cog_security']['admin_users']
  append false
end

ohai "reload_passwd" do
  action :nothing
  if (node['chef_packages']['ohai']['version'].to_i > 6) then
    plugin "etc"
  end
end
