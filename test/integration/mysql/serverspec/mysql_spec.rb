require 'spec_helper'

describe('mysql_database_test::default') do
  describe command("echo 'SHOW SCHEMAS;' | /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -pub3rs3kur3 | grep databass") do
    its(:exit_status) { should eq 0 }
  end

  describe command("echo 'SHOW SCHEMAS;' | /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -pub3rs3kur3 | grep datatrout") do
    its(:exit_status) { should eq 1 }
  end

  describe command("echo 'select User,Host from mysql.user;' | /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -pub3rs3kur3 | grep fozzie") do
    its(:exit_status) { should eq 0 }
  end

  describe command("echo 'select User,Host from mysql.user;' | /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -pub3rs3kur3 | grep kermit") do
    its(:exit_status) { should eq 1 }
  end
end
