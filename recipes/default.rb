#
# Cookbook Name:: cog_security
# Recipe:: default
#
# Copyright (C) 2015 Lauri Jesmin
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'sudo'

service "ssh" do
  service_name node['cog_security']['ssh_service_name']
  action :nothing
end

chef_gem 'chef-vault' do
  compile_time true if respond_to?(:compile_time)
end

require 'chef-vault'

begin
  rootuser=ChefVault::Item.load(node['cog_security']['bag_name'], "root")
rescue ChefVault::Exceptions::KeysNotFound => e
  log e.message
  log "Root user data is not found, root user is not managed"
  rootuser= Hash.new
end

user 'root' do
  action :manage
  password rootuser['password']
  only_if { rootuser['password'] }
end

node['cog_security']['admin_users'].each do |n|
  #User data from vault
  u=ChefVault::Item.load(node['cog_security']['bag_name'], n)

  ### Need to create user first
  home_dir=node['cog_security']['home_base'] + '/' + u['id']
  user u['id'] do
    action :create
    home home_dir
    manage_home true
    comment u['comment'] || ''
    shell u['shell'] || '/bin/bash'
    notifies :reload, "ohai[reload_passwd]", :immediately
  end

  directory "#{home_dir}/.ssh" do
    owner u['id']
    group lazy { node['etc']['passwd'][u['id']]['gid'] }
    mode "0700"
  end

  template "#{home_dir}/.ssh/authorized_keys" do
    source "authorized_keys.erb"
    cookbook 'cog_security'
    owner u['id']
    group lazy { node['etc']['passwd'][u['id']]['gid'] }
    mode "0600"
    variables :ssh_keys => u['ssh_keys']
    only_if {u['ssh_keys']}
  end
end

node['cog_security']['remove_users'].each do |n|
  user n do
    action :remove
  end
end

ruby_block "edit sshd_config" do
  only_if { node['cog_security']['ssh_disable_root_login'] }
  block do
    rc = Chef::Util::FileEdit.new("/etc/ssh/sshd_config")
    rc.insert_line_if_no_match(/^PermitRootLogin/, "PermitRootLogin no")
    rc.search_file_replace_line(/^PermitRootLogin/,"PermitRootLogin no")
    rc.write_file
  end
  notifies :restart, "service[ssh]"
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
