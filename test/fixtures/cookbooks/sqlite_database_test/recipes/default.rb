apt_update 'update'

# Load sqlite gem
include_recipe 'database::sqlite'

# point at localhost. hard code creds.
database = '/var/tmp/sqlite_user_database.db3'

sqlite_database 'Create database sqlite_user_database' do
  database_name database
  action :create
end

sqlite_database 'Create table users' do
  database_name database
  sql 'CREATE TABLE users(user TEXT);'
  action :query
end

sqlite_database 'Insert user peggie' do
  database_name database
  sql "INSERT INTO users (user) values ('peggie')"
  action :query
end

sqlite_database 'Insert user kermit' do
  database_name database
  sql "INSERT INTO users (user) values ('kermit')"
  action :query
end

sqlite_database 'Delete user peggie' do
  database_name database
  sql "DELETE FROM users WHERE user='peggie'"
  action :query
end
