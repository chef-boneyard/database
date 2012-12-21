# 
# Cookbook Name:: database
# Recipe:: databag
# 
# Copyright 2012, AT&T Foundry
#
# All rights reserved


begin
  database = node.name.gsub(/[.]/, "_")
  root_domain = "#{node['environment_code']}.#{node['zone_code']}.#{node['base_domain']}"
  master = "#{node["databases"]["master"]}.#{root_domain}"
  if node['databases']['use_internal'] then
    host = "#{node['databases']['master']}.#{node['internal_dns_code']}.#{root_domain}"
  else
    host = "#{node['databases']}.#{root_domain}"
  end

  query = "chef_environment:#{node.chef_environment} AND name:#{master}"
  Chef::Log.info "Finding database with query: #{query}"

  pg_server = search(:node, query).first
  if not pg_server then
    Chef::Log.error "Could not find postgresq databaase!"
  end
   
  connection_info = {:host => "#{host}", 
                   :username => 'postgres', 
                   :password => pg_server['postgresql']['password']['postgres']}
rescue NoMethodError
  Chef::Log.error "Failed to create database(s) for #{node[:fqdn]}"
  raise
end

# we create a user with the same name aas the db and set a random password
::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)
node["postgresql"] = {} if node["postgresql"].nil?
node["postgresql"]["users"] = {} if node["postgresql"]["users"].nil?
node.set_unless["postgresql"]["users"][database] = secure_password

postgresql_database_user node.name.gsub(/[.]/, "_") do
  connection connection_info
  password node["postgresql"]["users"][database]
  action :create
end

postgresql_database node.name.gsub(/[.]/, "_") do
  connection connection_info
  owner database
  action :create
end
