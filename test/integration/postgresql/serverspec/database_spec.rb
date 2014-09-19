require 'spec_helper'

describe command('export PGPASSWORD=\'mysql\'; export LC_ALL=C; psql -h localhost -p 5432 -U postgres -d mariadb_foo' \
                 ' -q -t -c \'SELECT 1\'') do
  it { should return_stdout '1' }
end

describe command('export PGPASSWORD=\'Foutoir\'; export LC_ALL=C; psql -h localhost -p 5432 -U mariadb_foo_user' \
                 ' -q -t -d mariadb_foo -c \'SELECT 1\'') do
  it { should return_stdout '1' }
end
