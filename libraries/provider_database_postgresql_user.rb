#
# Author:: Seth Chisamore (<schisamo@chef.io>)
# Author:: Lamont Granquist (<lamont@chef.io>)
# Author:: Marco Betti (<m.betti@gmail.com>)
# Copyright:: 2011-2015 Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require File.join(File.dirname(__FILE__), 'provider_database_postgresql')

class Chef
  class Provider
    class Database
      class PostgresqlUser < Chef::Provider::Database::Postgresql
        include Chef::Mixin::ShellOut

        def load_current_resource
          Gem.clear_paths
          require 'pg'
          @current_resource = Chef::Resource::DatabaseUser.new(@new_resource.name)
          @current_resource.username(@new_resource.name)
          @current_resource
        end

        def action_create
          unless exists?
            begin
              options = ''
              options += " PASSWORD '#{@new_resource.password}'" if @new_resource.password

              # Options from Postgresql specific resource
              options += " #{@new_resource.createdb ? 'CREATEDB' : 'NOCREATEDB'}" if @new_resource.respond_to?(:createdb)
              options += " #{@new_resource.createrole ? 'CREATEROLE' : 'NOCREATEROLE'}" if @new_resource.respond_to?(:createrole)
              options += " #{@new_resource.login ? 'LOGIN' : 'NOLOGIN'}" if @new_resource.respond_to?(:login)
              options += " #{@new_resource.replication ? 'REPLICATION' : 'NOREPLICATION'}" if @new_resource.respond_to?(:replication) && version_greater_than?(90_100)
              options += " #{@new_resource.superuser ? 'SUPERUSER' : 'NOSUPERUSER'}" if @new_resource.respond_to?(:superuser)

              # Options from a non Postgresql specific resource
              options += " #{Chef::Resource::PostgresqlDatabaseUser::CREATE_DB_DEFAULT ? 'CREATEDB' : 'NOCREATEDB'}" unless @new_resource.respond_to?(:createdb)
              options += " #{Chef::Resource::PostgresqlDatabaseUser::CREATE_ROLE_DEFAULT ? 'CREATEROLE' : 'NOCREATEROLE'}" unless @new_resource.respond_to?(:createrole)
              options += " #{Chef::Resource::PostgresqlDatabaseUser::LOGIN_DEFAULT ? 'LOGIN' : 'NOLOGIN'}" unless @new_resource.respond_to?(:login)
              options += " #{Chef::Resource::PostgresqlDatabaseUser::REPLICATION_DEFAULT ? 'REPLICATION' : 'NOREPLICATION'}" unless @new_resource.respond_to?(:replication) || !version_greater_than?(90_100)
              options += " #{Chef::Resource::PostgresqlDatabaseUser::SUPERUSER_DEFAULT ? 'SUPERUSER' : 'NOSUPERUSER'}" unless @new_resource.respond_to?(:superuser)

              statement = "CREATE USER \"#{@new_resource.username}\""
              statement += " WITH #{options}" unless options.empty?

              db('template1').query(statement)
              @new_resource.updated_by_last_action(true)
            ensure
              close
            end
          end
        end

        def action_drop
          if exists?
            begin
              db('template1').query("DROP USER \"#{@new_resource.username}\"")
              @new_resource.updated_by_last_action(true)
            ensure
              close
            end
          end
        end

        def action_grant
          grant_statement = "GRANT #{@new_resource.privileges.join(', ')} ON DATABASE \"#{@new_resource.database_name}\" TO \"#{@new_resource.username}\""
          Chef::Log.info("#{@new_resource}: granting access with statement [#{grant_statement}]")
          db(@new_resource.database_name).query(grant_statement)
          @new_resource.updated_by_last_action(true)
        ensure
          close
        end

        def action_grant_schema
          grant_statement = "GRANT #{@new_resource.privileges.join(', ')} ON SCHEMA \"#{@new_resource.schema_name}\" TO \"#{@new_resource.username}\""
          Chef::Log.info("#{@new_resource}: granting access with statement [#{grant_statement}]")
          db(@new_resource.database_name).query(grant_statement)
          @new_resource.updated_by_last_action(true)
        ensure
          close
        end

        private

        def exists?
          begin
            exists = db('template1').query("SELECT * FROM pg_user WHERE usename='#{@new_resource.username}'").num_tuples != 0
          ensure
            close
          end
          exists
        end
      end
    end
  end
end
