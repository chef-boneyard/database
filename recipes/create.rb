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
    host = "#{node['databases']["master"]}.#{root_domain}"
  end

  query = "chef_environment:#{node.chef_environment} AND name:#{master}"
  Chef::Log.info "Finding database with query: #{query}"

  pg_server = search(:node, query).first
  if not pg_server then
    throw "Could not find postgresql database!"
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

node.postgresql = {} unless node.has_key? 'postgresql'

# Chef::Log.info "node.postgresql: #{node.postgresql.inspect}"
# Chef::Log.info "node.postgresql.users exist? #{node.postgresql.has_key? 'users'}"
# node.postgresql.users exist
# type is array

node.postgresql.users = [] unless node.postgresql.has_key? 'users'

Chef::Log.info "Node.Postgresql.Users: #{node.postgresql.users.to_s}"
# BUG the node attribute is always an empty array on chef-client run
# does not retain the old data

key_pair = node.postgresql.users.detect {|u| u.has_key? database} || {}

node.postgresql.users << key_pair = { database => secure_password } if not key_pair.has_key? database

# Chef::Log.info "node.postgresql.users: #{node.postgresql.users.to_s}"
Chef::Log.info "Database: #{database}"
Chef::Log.info "Password: #{node.postgresql.users.detect {|u| u.has_key? database}}"
Chef::Log.info "Node.Postgresql.Users: #{node.postgresql.users.to_s}"

postgresql_database_user node.name.gsub(/[.]/, "_") do
  connection connection_info
  password key_pair[database]
  action :create
end

postgresql_database node.name.gsub(/[.]/, "_") do
  connection connection_info
  owner database
  action :create
end
