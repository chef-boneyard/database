# comments!

mysql_service 'default' do
  version node['mysql']['version']
  port '3306'
  initial_root_password 'an password'
  action [:create, :start]
end

mysql2_chef_gem 'default' do
  client_version node['mysql']['version']
  action :install
end

mysql_database 'databass' do
  connection(
    host: '127.0.0.1',
    username: 'root',
    password: 'an password'
    )
  action :create
end
