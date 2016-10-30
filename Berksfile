source 'https://supermarket.chef.io'

metadata

group :integration do
  cookbook 'selinux'
  cookbook 'mysql2_chef_gem'
  cookbook 'postgresql'
end

cookbook 'sqlite_database_test', path: 'test/fixtures/cookbooks/sqlite_database_test'
cookbook 'mysql_database_test', path: 'test/fixtures/cookbooks/mysql_database_test'
cookbook 'postgresql_database_test', path: 'test/fixtures/cookbooks/postgresql_database_test'
