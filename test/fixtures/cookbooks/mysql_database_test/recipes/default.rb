apt_update 'update'

# point at localhost. hard code creds.
connection_info = {
  host: '127.0.0.1',
  username: 'root',
  password: 'ub3rs3kur3',
}

# loosely coupled prerequisite
mysql2_chef_gem 'default' do
  client_version node['mysql']['version'] if node['mysql'] && node['mysql']['version']
  action :install
end

# Create a mysql_service to test against
mysql_service 'default' do
  version node['mysql']['version'] if node['mysql'] && node['mysql']['version']
  port '3306'
  initial_root_password 'ub3rs3kur3'
  action [:create, :start]
end

# Create a schema to test mysql_database :drop against
bash 'create datatrout' do
  code <<-EOF
  echo 'CREATE SCHEMA datatrout;' | /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -pub3rs3kur3;
  touch /tmp/troutmarker
  EOF
  not_if 'test -f /tmp/troutmarker'
  action :run
end

# Create a database for testing existing grant operations
bash 'create datasalmon' do
  code <<-EOF
  echo 'CREATE SCHEMA datasalmon;' | /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -pub3rs3kur3;
  touch /tmp/salmonmarker
  EOF
  not_if 'test -f /tmp/salmonmarker'
  action :run
end

# Create a user to test mysql_database_user :drop against
bash 'create kermit' do
  code <<-EOF
  echo "CREATE USER 'kermit'@'localhost';" | /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -pub3rs3kur3;
  touch /tmp/kermitmarker
  EOF
  not_if 'test -f /tmp/kermitmarker'
  action :run
end

# Create a user to test mysql_database_user password update via :create
bash 'create rowlf' do
  code <<-EOF
  echo "CREATE USER 'rowlf'@'localhost' IDENTIFIED BY 'hunter2';" | /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -pub3rs3kur3;
  touch /tmp/rowlfmarker
  EOF
  not_if 'test -f /tmp/rowlfmarker'
  action :run
end

# Create a user to test mysql_database_user password update via :create using a password hash
bash 'create statler' do
  code <<-EOF
  echo "CREATE USER 'statler'@'localhost' IDENTIFIED BY 'hunter2';" | /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -pub3rs3kur3;
  touch /tmp/statlermarker
  EOF
  not_if 'test -f /tmp/statlermarker'
  action :run
end

# Create a user to test mysql_database_user password update via :grant
bash 'create rizzo' do
  code <<-EOF
  echo "GRANT SELECT ON datasalmon.* TO 'rizzo'@'127.0.0.1' IDENTIFIED BY 'hunter2';" | /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -pub3rs3kur3;
  touch /tmp/rizzomarker
  EOF
  not_if 'test -f /tmp/rizzomarker'
  action :run
end

## Resources we're testing
mysql_database 'databass' do
  connection connection_info
  action :create
end

mysql_database 'datatrout' do
  connection connection_info
  action :drop
end

mysql_database_user 'piggy' do
  connection connection_info
  action :create
end

mysql_database_user 'kermit' do
  connection connection_info
  action :drop
end

mysql_database_user 'rowlf' do
  connection connection_info
  password '123456' # hashed: *6BB4837EB74329105EE4568DDA7DC67ED2CA2AD9
  action :create
end

mysql_database_user 'statler' do
  connection connection_info
  password hashed_password('*2027D9391E714343187E07ACB41AE8925F30737E'); # 'l33t'
  action :create
end

mysql_database_user 'fozzie' do
  connection connection_info
  database_name 'databass'
  password 'wokkawokka'
  host 'mars'
  privileges [:select, :update, :insert]
  require_ssl true
  action :grant
end

mysql_database_user 'moozie' do
  connection connection_info
  database_name 'databass'
  password hashed_password('*F798E7C0681068BAE3242AA2297D2360DBBDA62B')
  host '127.0.0.1'
  privileges [:select, :update, :insert]
  require_ssl false
  action :grant
end

# all the grants exist ('Granting privs' should not show up), but the password is different
# and should get updated
mysql_database_user 'rizzo' do
  connection connection_info
  database_name 'datasalmon'
  password 'salmon'
  host '127.0.0.1'
  privileges [:select]
  require_ssl false
  action :grant
end

mysql_database 'flush repl privileges' do
  connection connection_info
  database_name 'databass'
  sql 'flush privileges'
  action :query
end
