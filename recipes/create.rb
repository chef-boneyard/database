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

Chef::Log.info "Node.Postgresql value #{node.postgresql.current_normal.to_s}"
Chef::Log.info "Node.Postgresql exists? #{node.has_key? 'postgresql'}"
node.set['postgresql'] = {} unless node.has_key? 'postgresql'

Chef::Log.info "Node.Postgresql.User exist? #{node.postgresql.has_key? 'users'}"
node.set['postgresql']['users'] = [] unless node.postgresql.has_key? 'users'

Chef::Log.info "Node.Postgresql.User: #{node.postgresql.users.to_s}"
db_password = secure_password
key_pair = node.postgresql.users.detect {|u| u.has_key? database} || {}

Chef::Log.info "Key Pair: #{key_pair}"

node.postgresql.users << key_pair = {database => db_password} unless key_pair.has_key? database

Chef::Log.info "Generated Password: #{db_password} Key Pair: #{key_pair}"

Chef::Log.info "Database: #{database}"
Chef::Log.info "Password: #{node.postgresql.users.detect {|u| u.has_key? database}}"
Chef::Log.info "Node.Postgresql.Users: #{node.postgresql.current_normal.to_s}"

pg_user = postgresql_database_user node.name.gsub(/[.]/, "_") do
  connection connection_info
  password db_password
  action :create # unless exists?
end

pg_db = postgresql_database node.name.gsub(/[.]/, "_") do
  connection connection_info
  owner database
  action :create # unless exists?
end

# PUCK-99 in-progress
# resources has an updated_by_last_action that might be useful
# Chef::Log.info "PG_USER #{database} (re)created? #{pg_user.inspect}"
# key_pair[database] = db_password if pg_user.exists?
# Chef::Log.info "Node.Postgresql.Users: #{node.postgresql.current_normal.to_s}"
