# Database cookbook CHANGELOG

This file is used to list changes made in each version of the database cookbook.

## v5.0.0 (2016-03-23)

- Removed Chef 10 compatibility checks
- Resolved the following error in the sql_server_user provider: undefined local variable or method `sql_role`
- Added a timeout attribute to the database provider on sql_server, which defaults to 120 seconds
- Fixed the :revoke action for the database_user provider on mysql
- Removed duplicate documentation from the readme
- Updated the mysql_user provider to compare passwords so passwords can be updated
- Updated documentation for the connection hash in the database provider
- Removed duplicate amazon supports property from the metadata
- Removed documentation for ebs recipes that are no longer part of this cookbook
- Updated testing deps and removed the large number of Guard deps
- Fixed intgration tests to be in the correct location so they run as expected
- Added .foodcritic file to ignore FC023
- Removed the cloud testing Kitchen file and Gem dependencies
- Added integration testing with Kitchen Docker in Travis CI

## v4.0.9 (2015-09-07)

- Fix bad attribute name with postgresql_database in the readme
- Add `flags` attribute to the mysql provider
- Add `database` attribute to the mysql provider
- Use the correct database with the mssql provider
- Updated testing.md and contributing.md to point to documentation in the new community_cookbook_documentation repo
- Add oracle as a supported platform in the metadata
- Add source_url and issues_url metadata
- Add cookbook version and travis badges to the readme
- Clarify the minimum required Chef version in the readme
- Add a Travis config
- Resolve several rubocop and foodcritic warnings
- Update all platforms in the Kitchen config
- Update development dependencies to the latest releases
- Add a maintainers.md and maintainers.toml file
- Add a chefignore file
- Update list of ignored files in the gitignore

## v4.0.8 (2015-08-03)

- 139 - Use a more reliable method of determining whether the
- Postgres server accepts the REPLICATION attribute on user creation.

## v4.0.7 (2015-07-27)

- 161 - Fixes multiple issues causing the MySQL database user creation to not be idempotent

## v4.0.6 (2015-04-29)

- 126 - Use sql_query property instead of sql in the mysql provider for :query action

## v4.0.5 (2015-04-08)

- 137/#138 - Removing log message containing password information

## v4.0.4 (2015-04-07)

- Using unescaped db name in field value

## v4.0.3 (2015-02-22)

- Unbreak postgresql_database_resource on older versions of PostgreSQL

## v4.0.2 (2015-02-09)

- Removing leftover mysql recipe that installs the mysql2_chef_gem.

## v4.0.1 (2015-02-05)

- Fixing merge conflicts with master on 4.0.0 attempted release

## v4.0.0 (2015-02-05)

- Decoupled mysql2_chef_gem cookbook.
- Users must now install it themselves before utilizing mysql_database
- or mysql_database_user resources.
- Fixing various MilClass errors in mysql providers
- Restoring missing :query action for mysql
- Restoring grant_option support for mysql
- Adding revoke action for mysql

## v3.1.0 (2015-01-30)

- Add support for postgresql_database_user privileges
- Add postgresql_database_test cookbook to test/fixtures

## v3.0.3 (2015-01-20)

- Bugfix: bugfix: lack of node['mysql']['version'] causing NilClass error

## v3.0.2 (2015-01-16)

- Fix bug to allow grants on databases with special characters

## v3.0.1 (2015-01-16)

- Enabling ssl for provider_mysql_database_user

## v3.0.0 (2015-01-15)

- Removing out of scope recipes
- porting to mysql2_chef_gem
- adding test-kitchen suites for mysql

## v2.3.1 (2014-12-13)

- Locking mysql and mysql-chef_gem dependencies down in metadata.rb

## v2.3.0 (2014-08-13)

- [#62] Allow requiring SSL

## v2.2.0 (2014-05-07)

- [COOK-4626] Add windows users for SQL Server
- [COOK-4627] Assigning sys_roles in SQL Server

## v2.1.10 (2014-05-07)

- [COOK-4614] - Update README to reflect gem installation via mysql-chef_gem

## v2.1.8 (2014-04-23)

- [COOK-4583] - Add ChefSpec matchers

## v2.1.6 (2014-04-10)

- [COOK-4538] Bump supported Chef version

## v2.1.4 (2014-04-09)

[COOK-4529] Query action ignores MySQL errors

## v2.1.2 (2014-04-01)

- Depending on mysql-chef_gem cookbook

## v2.1.0 (2014-03-31)

- Updating mysql cookbook dependency
- Enforcing rubocops

## v2.0.0 (2014-02-25)

[COOK-3441] database_user password argument should not be required

## v1.6.0

### New Feature

- **[COOK-4009](https://tickets.chef.io/browse/COOK-4009)** - Add PostgreSQL SCHEMA management capability

### Improvement

- **[COOK-3862](https://tickets.chef.io/browse/COOK-3862)** - Improve database cookbook documentation

## v1.5.2

### Improvement

- **[COOK-3716](https://tickets.chef.io/browse/COOK-3716)** - Add ALTER SQL Server user roles

## v1.5.0

### Improvement

- **[COOK-3546](https://tickets.chef.io/browse/COOK-3546)** - Add connection parameters `:socket`
- **[COOK-1709](https://tickets.chef.io/browse/COOK-1709)** - Add 'grant_option' parameter

## v1.4.0

### Bug

- [COOK-2074]: Regex in exists? check in `sql_server_database` resource should match for start and end of line
- [COOK-2561]: `mysql_database_user` can't set global grants

### Improvement

- [COOK-2075]: Support the collation attribute in the `database_sql_server` provider

## v1.3.12

- [COOK-850] - `postgresql_database_user` doesn't have example

## v1.3.10

- [COOK-2117] - undefined variable `grant_statement` in mysql user provider

## v1.3.8

- [COOK-1896] - Escape command
- [COOK-2047] - Chef::Provider::Database::MysqlUser action :grant improperly quotes `username`@`host` string
- [COOK-2060] - Mysql::Error: Table '_._' doesn't exist when privileges include SELECT and database/table attributes are nil
- [COOK-2062] - Remove backticks from database name when using wildcard

## v1.3.6

- [COOK-1688] - fix typo in readme and add amazon linux to supported platforms

## v1.3.4

- [COOK-1561] - depend on mysql 1.3.0+ explicitly
- depend on postgresql 1.0.0 explicitly

## v1.3.2

- Update the version for release (oops)

## v1.3.0

- [COOK-932] - Add mysql recipe to conveniently include mysql::ruby
- [COOK-1228] - database resource should be able to execute scripts on disk
- [COOK-1291] - make the snapshot retention policy less confusing
- [COOK-1401] - Allow to specify the collation of new databases
- [COOK-1534] - Add postgresql recipe to conveniently include postgresql::ruby

## v1.2.0

- [COOK-970] - workaround for disk [re]naming on ubuntu 11.04+
- [COOK-1085] - check RUBY_VERSION and act accordingly for role
- [COOK-749] - localhost should be a string in snapshot recipe

## v1.1.4

- [COOK-1062] - Databases: Postgres exists should close connection

## v1.1.2

- [COOK-975] - Change arg='DEFAULT' to arg=nil, :default => 'DEFAULT'
- [COOK-964] - Add parentheses around connection hash in example

## v1.1.0

- [COOK-716] - providers for PostgreSQL

## v1.0.0

- [COOK-683] - added `database` and `database_user` resources
- [COOK-684] - MySQL providers
- [COOK-685] - SQL Server providers
- refactored - `database::master` and `database::snapshot` recipes to leverage new resources

## v0.99.1

- Use Chef 0.10's `node.chef_environment` instead of `node['app_environment']`.
