#
# Author:: Seth Chisamore (<schisamo@chef.io>)
# Author:: Sean OMeara (<sean@chef.io>)
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

require File.join(File.dirname(__FILE__), 'provider_database_mysql')

class Chef
  class Provider
    class Database
      class MysqlUser < Chef::Provider::Database::Mysql
        use_inline_resources if defined?(use_inline_resources)

        def whyrun_supported?
          true
        end

        action :create do
          # test
          user_present = nil
          begin
            test_sql = "SELECT User,Host from mysql.user WHERE User='#{new_resource.username}' AND Host='#{new_resource.host}';"
            test_sql_results = test_client.query(test_sql)
            test_sql_results.each do |r|
              user_present = true if r['User'] == new_resource.username
            end
          ensure
            close_test_client
          end

          # repair
          unless user_present
            converge_by "Creating user '#{new_resource.username}'@'#{new_resource.host}'" do
              begin
                repair_sql = "CREATE USER '#{new_resource.username}'@'#{new_resource.host}'"
                repair_sql += " IDENTIFIED BY '#{new_resource.password}'" if new_resource.password
                repair_client.query(repair_sql)
              ensure
                close_repair_client
              end
            end
          end
        end

        action :drop do
          # test
          user_present = nil
          begin
            test_sql = 'SELECT User,Host'
            test_sql += ' from mysql.user'
            test_sql += " WHERE User='#{new_resource.username}'"
            test_sql += " AND Host='#{new_resource.host}'"
            test_sql_results = test_client.query test_sql
            test_sql_results.each do |r|
              user_present = true if r['User'] == new_resource.username
            end
          ensure
            close_test_client
          end

          # repair
          if user_present
            converge_by "Dropping user '#{new_resource.username}'@'#{new_resource.host}'" do
              begin
                repair_sql = 'DROP USER'
                repair_sql += " '#{new_resource.username}'@'#{new_resource.host}'"
                repair_client.query repair_sql
              ensure
                close_repair_client
              end
            end
          end
        end

        action :grant do
          # gratuitous function
          def ishash?
            return true if (/(\A\*[0-9A-F]{40}\z)/i).match(new_resource.password)
          end

          db_name = new_resource.database_name ? "`#{new_resource.database_name}`" : '*'
          tbl_name = new_resource.table ? new_resource.table : '*'

          # Test
          incorrect_privs = nil
          begin
            test_sql = 'SELECT * from mysql.db'
            test_sql += " WHERE User='#{new_resource.username}'"
            test_sql += " AND Host='#{new_resource.host}'"
            test_sql += " AND Db='#{new_resource.database_name}'"
            test_sql_results = test_client.query test_sql

            incorrect_privs = true if test_sql_results.size == 0
            # These should all by 'Y'
            test_sql_results.each do |r|
              new_resource.privileges.each do |p|
                key = "#{p.capitalize}_priv"
                incorrect_privs = true if r[key] != 'Y'
              end
            end
          ensure
            close_test_client
          end

          # Repair
          if incorrect_privs
            converge_by "Granting privs for '#{new_resource.username}'@'#{new_resource.host}'" do
              begin
                repair_sql = "GRANT #{new_resource.privileges.join(',')}"
                repair_sql += " ON #{db_name}.#{tbl_name}"
                repair_sql += " TO '#{new_resource.username}'@'#{new_resource.host}' IDENTIFIED BY"
                repair_sql += " '#{new_resource.password}'"
                repair_sql += ' REQUIRE SSL' if new_resource.require_ssl
                repair_sql += ' WITH GRANT OPTION' if new_resource.grant_option

                repair_client.query(repair_sql)
                repair_client.query('FLUSH PRIVILEGES')
              ensure
                close_repair_client
              end
            end
          end
        end

        def action_revoke
          db_name = new_resource.database_name ? "`#{new_resource.database_name}`" : '*'
          tbl_name = new_resource.table ? new_resource.table : '*'

          revoke_statement = "REVOKE #{@new_resource.privileges.join(', ')}"
          revoke_statement += " ON #{db_name}.#{tbl_name}"
          revoke_statement += " FROM `#{@new_resource.username}`@`#{@new_resource.host}` "
          Chef::Log.info("#{@new_resource}: revoking access with statement [#{revoke_statement}]")
          db.query(revoke_statement)
          @new_resource.updated_by_last_action(true)
        ensure
          close
        end

      end
    end
  end
end
