require 'spec_helper'

psql = 'env PGPASSWORD=raaaaaaaaaaaaaaaaaaaaaaaaaaaaah psql -h 127.0.0.1 -U animal -d postgres'
psql_user = 'env PGPASSWORD=raaaaaaaaaaaaaaaaaaaaaaaaaaaaah psql -h 127.0.0.1 -U human -d dataflounder'

describe('postgresql_database_test::default') do
  # check that superuser has access to the test database
  describe command("#{psql} -c 'SELECT * from pg_database;' | grep dataflounder") do
    its(:exit_status) { should eq 0 }
  end

  # check grants from normal user on test database and schema
  describe command("#{psql_user} -c '\\dt' | grep person") do
    its(:exit_status) { should eq 0 }
  end

  describe command("#{psql} -c 'SELECT * from pg_database;' | grep datacarp") do
    its(:exit_status) { should eq 1 }
  end

  # a bit superfluous as we are using animal to execute these queries, but whatevs
  describe command("#{psql} -c 'SELECT * from pg_shadow;' | grep animal") do
    its(:exit_status) { should eq 0 }
  end

  describe command("#{psql} -c 'SELECT * FROM pg_shadow;' | grep gonzo") do
    its(:exit_status) { should eq 1 }
  end
end
