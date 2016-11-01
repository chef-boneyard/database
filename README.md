# Database Cookbook

[![Build Status](https://travis-ci.org/chef-cookbooks/database.svg?branch=master)](http://travis-ci.org/chef-cookbooks/database) [![Cookbook Version](http://img.shields.io/cookbook/v/database.svg)](https://supermarket.chef.io/cookbooks/database)

The main highlight of this cookbook is the `database` and `database_user` resources for managing databases and database users in a RDBMS. Providers for MySQL, PostgreSQL and SQL Server are also provided, see usage documentation below.

## Requirements

### Platforms

- Debian / Ubuntu derivatives
- RHEL derivatives
- Fedora

### Chef

- Chef 12.1+

### Cookbooks

- postgresql

## Resources/Providers

These resources aim to expose an abstraction layer for interacting with different RDBMS in a general way. Currently the cookbook ships with providers for MySQL, PostgreSQL and SQL Server. Please see specific usage in the **Example** sections below. The providers use specific Ruby gems installed under Chef's Ruby environment to execute commands and carry out actions. These gems will need to be installed before the providers can operate correctly. Specific notes for each RDBS flavor:

- MySQL: leverages the `mysql2` gem, which can be installed with the `mysql2_chef_gem` resource prior to use (available on the Supermarket). You must depend on the `mysql2_chef_gem` cookbook, then use a `mysql2_chef_gem` resource to install it. The resource allows the user to select MySQL client library versions, as well as optionally select MariaDB libraries.

- PostgreSQL: leverages the `pg` gem which is installed as part of the `postgresql::ruby` recipe. You must declare `include_recipe "database::postgresql"` to include this.

- SQL Server: leverages the `tiny_tds` gem which is installed as part of the `sql_server::client` recipe.

- SQLite: leverages the `sqlite3` gem which is installed as part of the `database::sqlite` recipe. You must declare `include_recipe "database::sqlite"` to include this.

### database

Manage databases in a RDBMS. Use the proper shortcut resource depending on your RDBMS: `mysql_database`, `postgresql_database`, `sql_server_database` or `sqlite_database`.

#### Actions

- `:create`: create a named database
- `:drop`: drop a named database
- `:query`: execute an arbitrary query against a named database

#### Attribute Parameters

- database_name: name attribute. Name of the database to interact with
- connection: hash of connection info. valid keys include `:host`, `:port`, `:username`, and `:password`

  - only for MySQL DB*:

    - `:flags` (see `Mysql2::Client@@default_query_options[:connect_flags]`)
    - `:default_file`, `:default_group` (see <https://github.com/brianmario/mysql2#reading-a-mysql-config-file>)

  - only for PostgreSQL: `:database` (overwrites parameter `database_name`)

  - not used for SQLlite

- sql: string of sql or a block that executes to a string of sql, which will be executed against the database. used by `:query` action only

- The database cookbook uses the `mysql2` gem.

> "The value of host may be either a host name or an IP address. If host is NULL or the string "127.0.0.1", a connection to the local host is assumed. For Windows, the client connects using a shared-memory connection, if the server has shared-memory connections enabled. Otherwise, TCP/IP is used. For a host value of "." on Windows, the client connects using a named pipe, if the server has named-pipe connections enabled. If named-pipe connections are not enabled, an error occurs."

If you specify a `:socket` key and are using the mysql_service resource to set up the MySQL service, you'll need to specify the path in the form `/var/run/mysql-<instance name>/mysqld.sock`.

#### Providers

- `Chef::Provider::Database::Mysql`: shortcut resource `mysql_database`
- `Chef::Provider::Database::Postgresql`: shortcut resource `postgresql_database`
- `Chef::Provider::Database::SqlServer`: shortcut resource `sql_server_database`
- `Chef::Provider::Database::Sqlite`: shortcut resource `sqlite_database`

#### Examples

```ruby
# Create a mysql database
mysql_database 'wordpress-cust01' do
  connection(
    :host     => '127.0.0.1',
    :username => 'root',
    :password => node['wordpress-cust01']['mysql']['initial_root_password']
  )
  action :create
end
```

```ruby
# Create a mysql database on a named mysql instance
mysql_database 'oracle_rools' do
  connection(
    :host     => '127.0.0.1',
    :username => 'root',
    :socket   => "/var/run/mysql-#{instance-name}/mysqld.sock"
    :password => node['mysql']['server_root_password']
  )
  action :create
end
```

```ruby
# Create a sql server database
sql_server_database 'mr_softie' do
  connection(
    :host     => '127.0.0.1',
    :port     => node['sql_server']['port'],
    :username => 'sa',
    :password => node['sql_server']['server_sa_password'],
    :options  => { 'ANSI_NULLS' => 'ON', 'QUOTED_IDENTIFIER' => 'OFF' }
  )
  action :create
end
```

```ruby
# create a postgresql database
postgresql_database 'mr_softie' do
  connection(
    :host      => '127.0.0.1',
    :port      => 5432,
    :username  => 'postgres',
    :password  => node['postgresql']['password']['postgres']
  )
  action :create
end
```

```ruby
# create a postgresql database with additional parameters
postgresql_database 'mr_softie' do
  connection(
    :host     => '127.0.0.1',
    :port     => 5432,
    :username => 'postgres',
    :password => node['postgresql']['password']['postgres']
  )
  template 'DEFAULT'
  encoding 'DEFAULT'
  tablespace 'DEFAULT'
  connection_limit '-1'
  owner 'postgres'
  action :create
end
```

```ruby
# Externalize conection info in a ruby hash
mysql_connection_info = {
  :host     => '127.0.0.1',
  :username => 'root',
  :password => node['mysql']['server_root_password']
}

sql_server_connection_info = {
  :host     => '127.0.0.1',
  :port     => node['sql_server']['port'],
  :username => 'sa',
  :password => node['sql_server']['server_sa_password']
}

postgresql_connection_info = {
  :host     => '127.0.0.1',
  :port     => node['postgresql']['config']['port'],
  :username => 'postgres',
  :password => node['postgresql']['password']['postgres']
}

# Same create commands, connection info as an external hash
mysql_database 'foo' do
  connection mysql_connection_info
  action :create
end

sql_server_database 'foo' do
  connection sql_server_connection_info
  action     :create
end

postgresql_database 'foo' do
  connection postgresql_connection_info
  action     :create
end

# Create database, set provider in resource parameter
database 'bar' do
  connection mysql_connection_info
  provider   Chef::Provider::Database::Mysql
  action     :create
end

database 'bar' do
  connection sql_server_connection_info
  provider   Chef::Provider::Database::SqlServer
  action     :create
end

database 'bar' do
  connection postgresql_connection_info
  provider   Chef::Provider::Database::Postgresql
  action     :create
end



# Drop a database
mysql_database 'baz' do
  connection mysql_connection_info
  action    :drop
end



# Query a database
mysql_database 'flush the privileges' do
  connection mysql_connection_info
  sql        'flush privileges'
  action     :query
end


# Query a database from a sql script on disk
mysql_database 'run script' do
  connection mysql_connection_info
  sql { ::File.open('/path/to/sql_script.sql').read }
  action :query
end



# Vacuum a postgres database
postgresql_database 'vacuum databases' do
  connection      postgresql_connection_info
  database_name 'template1'
  sql 'VACUUM FULL VERBOSE ANALYZE'
  action :query
end
```

```ruby
# Create, Insert, Query a SQLite database
# Note that inserting anything in to the database will create it automaticly.
sqlite_database 'mr_softie' do
  database_name '/path/to/database.db3'
  sql "sql command"
  action :query
end

# Delete the database, will remove the file
sqlite_database 'mr_softie' do
  database_name '/path/to/database.db3'
  action :drop
end
```

### database_user

Manage users and user privileges in a RDBMS. Use the proper shortcut resource depending on your RDBMS: `mysql_database_user`, `postgresql_database_user`, or `sql_server_database_user`.

#### Actions

- `:create`: create a user
- `:drop`: drop a user
- `:grant`: manipulate user privileges on database objects

#### Attribute Parameters

- username: name attribute. Name of the database user
- password: password for the user account
- database_name: Name of the database to interact with
- connection: hash of connection info. valid keys include :host, :port, :username, :password
- privileges: array of database privileges to grant user. used by the :grant action. default is :all
- host: host where user connections are allowed from. used by MySQL provider only. default is '127.0.0.1'
- table: table to grant privileges on. used by :grant action and MySQL provider only. default is '*' (all tables)
- require_ssl: true or false to force SSL connections to be used for user
- require_x509: true or false to force SSL with client certificate verification

#### Providers

- `Chef::Provider::Database::MysqlUser`: shortcut resource `mysql_database_user`
- `Chef::Provider::Database::PostgresqlUser`: shortcut resource `postgresql_database_user`
- `Chef::Provider::Database::SqlServerUser`: shortcut resource`sql_server_database_user`

#### Examples

```ruby
# create connection info as an external ruby hash
mysql_connection_info = {
  :host     => '127.0.0.1',
  :username => 'root',
  :password => node['mysql']['server_root_password']
}

postgresql_connection_info = {
  :host     => '127.0.0.1',
  :port     => node['postgresql']['config']['port'],
  :username => 'postgres',
  :password => node['postgresql']['password']['postgres']
}

sql_server_connection_info = {
  :host     => '127.0.0.1',
  :port     => node['sql_server']['port'],
  :username => 'sa',
  :password => node['sql_server']['server_sa_password']
}

# Create a mysql user but grant no privileges
mysql_database_user 'disenfranchised' do
  connection mysql_connection_info
  password   'super_secret'
  action     :create
end

# Do the same but pass the provider to the database resource
database_user 'disenfranchised' do
  connection mysql_connection_info
  password   'super_secret'
  provider   Chef::Provider::Database::MysqlUser
  action     :create
end

# Create a postgresql user but grant no privileges
postgresql_database_user 'disenfranchised' do
  connection postgresql_connection_info
  password   'super_secret'
  action     :create
end

# The same as above but utilizing hashed password string instead of
# plain text one
postgresql_database_user 'disenfranchised' do
  connection    postgresql_connection_info
  password      hashed_password('md5eacdbf8d9847a76978bd515fae200a2a')
  action        :grant
end

# Do the same but pass the provider to the database resource
database_user 'disenfranchised' do
  connection postgresql_connection_info
  password   'super_secret'
  provider   Chef::Provider::Database::PostgresqlUser
  action     :create
end

# Create a sql server user but grant no privileges
sql_server_database_user 'disenfranchised' do
  connection sql_server_connection_info
  password   'super_secret'
  action     :create
end

# Drop a mysql user
mysql_database_user 'foo_user' do
  connection mysql_connection_info
  action     :drop
end

# Bulk drop sql server users
%w(disenfranchised foo_user).each do |user|
  sql_server_database_user user do
    connection sql_server_connection_info
    action     :drop
  end
end

# Grant SELECT, UPDATE, and INSERT privileges to all tables in foo db from all hosts
mysql_database_user 'foo_user' do
  connection    mysql_connection_info
  password      'super_secret'
  database_name 'foo'
  host          '%'
  privileges    [:select,:update,:insert]
  action        :grant
end

# The same as above but utilizing hashed password string instead of
# plain text one
mysql_database_user 'foo_user' do
  connection    mysql_connection_info
  password      hashed_password('*664E8D709A6EBADFC68361EBE82CF77F10211E52')
  database_name 'foo'
  host          '%'
  privileges    [:select,:update,:insert]
  action        :grant
end

# Grant all privileges on all databases/tables from 127.0.0.1
mysql_database_user 'super_user' do
  connection mysql_connection_info
  password   'super_secret'
  action     :grant
end

# grant all privileges on all tables, sequences and functions in public schema of foo db
postgresql_database_user 'foo_user' do
  connection    postgresql_connection_info
  database_name 'foo'
  schema_name 'public'
  tables [:all]
  sequences [:all]
  functions [:all]
  privileges    [:all]
  action        [:grant, :grant_schema, :grant_table, :grant_sequence, :grant_function]
end

# grant select,update,insert privileges to all tables in foo db
sql_server_database_user 'foo_user' do
  connection    sql_server_connection_info
  password      'super_secret'
  database_name 'foo'
  privileges    [:select,:update,:insert]
  action        :grant
end
```

## License & Authors

**Author:** Cookbook Engineering Team ([cookbooks@chef.io](mailto:cookbooks@chef.io))

**Copyright:** 2009-2016, Chef Software, Inc.

```
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
