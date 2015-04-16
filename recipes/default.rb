#
# Cookbook Name:: cog_security
# Recipe:: default
#
# Copyright (C) 2015 Lauri Jesmin
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'users'
include_recipe 'sudo'

users_manage node['cog_security']['sudo_group'] do
  group_id node['cog_security']['sudo_group_id']
  data_bag node['cog_security']['bag_name']
end

service "ssh" do
  service_name node['cog_security']['ssh_service_name']
  action :nothing
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

rootuser=search(node['cog_security']['bag_name'],'id:root')

user 'root' do
  action :manage
  password rootuser.first['password']
  only_if { rootuser.count==1 }
end
