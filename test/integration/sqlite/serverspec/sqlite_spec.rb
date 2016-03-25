require 'spec_helper'

describe('sqlite_database_test::default') do
  describe command("sqlite3 /var/tmp/sqlite_user_database.db3 '.tables' | grep users") do
    its(:exit_status) { should eq 0 }
  end

  describe command("sqlite3 /var/tmp/sqlite_user_database.db3 'select * from users' | grep peggie") do
    its(:exit_status) { should eq 1 }
  end

  describe command("sqlite3 /var/tmp/sqlite_user_database.db3 'select * from users' | grep kermit") do
    its(:exit_status) { should eq 0 }
  end
end
