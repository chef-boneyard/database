require 'spec_helper'

describe command('/usr/bin/mysql -u root -pgsql' \
                 ' -D mysql -r -B -N -e "SELECT 1"') do
  it { should return_stdout '1' }
end

describe command('/usr/bin/mysql -u mariadb_foo_user -pFoutoir' \
                 ' -D mariadb_foo -r -B -N -e "SELECT 1"') do
  it { should return_stdout '1' }
end
