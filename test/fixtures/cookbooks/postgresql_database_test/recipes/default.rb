include_recipe 'postgresql::server'
include_recipe 'postgresql::ruby'

# point at localhost. hard code creds.
connection_info = {
  host: '127.0.0.1',
  port: '5432',
  username: 'postgres',
  password: node['postgresql']['password']['postgres']
}

# Create a database to test postgresql_database :drop against
bash 'create datacarp' do
  code <<-EOF
  su -c 'createdb datacarp' - postgresql
  touch /tmp/carpmarker
  EOF
  not_if 'test -f /tmp/carpmarker'
  action :run
end

# Create a user to test postgresql_database_user :drop against
bash 'create piggy' do
  code <<-EOF
  su -c 'createuser -DRS gonzo' - postgresql
  touch /tmp/piggymarker
  EOF
  not_if 'test -f gonzomarker'
  action :run
end

## resources we're testing
postgresql_database 'dataflounder' do
  connection connection_info
  database_name 'dataflounder'
  sql <<-EOF
    CREATE TABLE IF NOT EXISTS person (
      uid serial PRIMARY KEY,
      firstname varchar(50)  NULL CHECK (firstname <> ''),
      lastname varchar(50) NOT NULL CHECK (lastname <> '')
    );
  EOF
  action [:create, :query]
end

postgresql_database 'datacarp' do
  connection connection_info
  action :drop
end

postgresql_database_user 'animal' do
  connection connection_info
  password 'raaaaaaaaaaaaaaaaaaaaaaaaaaaaah'
  superuser true
  login true
  action :create
end

postgresql_database_user 'human' do
  connection connection_info
  password 'raaaaaaaaaaaaaaaaaaaaaaaaaaaaah'
  login true
  database_name 'dataflounder'
  schema_name 'public'
  action [:create, :grant, :grant_schema]
end

postgresql_database_user 'gonzo' do
  connection connection_info
  action :drop
end
