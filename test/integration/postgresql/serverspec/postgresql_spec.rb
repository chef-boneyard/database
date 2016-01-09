require 'spec_helper'

psql_as_animal = 'env PGPASSWORD=raaaaaaaaaaaaaaaaaaaaaaaaaaaaah psql -h 127.0.0.1 -U animal -d postgres'
psql_as_krusty = 'env PGPASSWORD=getbacktowork psql -h 127.0.0.1 -U krusty -d postgres'

describe('postgresql_database_test::default') do
  describe command("#{psql_as_animal} -c 'SELECT * from pg_database;' | grep dataflounder") do
    its(:exit_status) { should eq 0 }
  end

  describe command("#{psql_as_krusty} -c 'SELECT * from pg_database;' | grep dataflatfish") do
    its(:exit_status) { should eq 0 }
  end

  describe command("#{psql_as_animal} -c 'SELECT * from pg_database;' | grep datacarp") do
    its(:exit_status) { should eq 1 }
  end

  describe command("#{psql_as_krusty} -c 'SELECT * from pg_database;' | grep datacyprinidae") do
    its(:exit_status) { should eq 1 }
  end

  # a bit superfluous as we are using animal to execute these queries, but whatevs
  describe command("#{psql_as_animal} -c 'SELECT * from pg_shadow;' | grep animal") do
    its(:exit_status) { should eq 0 }
  end

  # krusty is not an admin as animal is, so we have to use animal to check for crusty in pg_shadow
  describe command("#{psql_as_animal} -c 'SELECT * from pg_shadow;' | grep krusty") do
    its(:exit_status) { should eq 0 }
  end

  describe command("#{psql_as_animal} -c 'SELECT * FROM pg_shadow;' | grep gonzo") do
    its(:exit_status) { should eq 1 }
  end

  describe command("#{psql_as_krusty} -c 'SELECT * FROM pg_shadow;' | grep patrick") do
    its(:exit_status) { should eq 1 }
  end
end
