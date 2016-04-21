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
        use_inline_resources

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

            password_up_to_date = !user_present || test_user_password
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

          update_user_password unless password_up_to_date
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
            return true if /(\A\*[0-9A-F]{40}\z)/i =~ new_resource.password
          end

          db_name = new_resource.database_name ? "`#{new_resource.database_name}`" : '*'
          tbl_name = new_resource.table ? new_resource.table : '*'
          test_table = new_resource.database_name ? 'mysql.db' : 'mysql.user'

          # Test
          incorrect_privs = nil
          begin
            test_sql = "SELECT * from #{test_table}"
            test_sql += " WHERE User='#{new_resource.username}'"
            test_sql += " AND Host='#{new_resource.host}'"
            test_sql += " AND Db='#{new_resource.database_name}'" if new_resource.database_name
            test_sql_results = test_client.query test_sql

            incorrect_privs = true if test_sql_results.size == 0
            # These should all be 'Y'
            test_sql_results.each do |r|
              desired_privs.each do |p|
                key = p.to_s.capitalize.tr(' ', '_').gsub('Replication_', 'Repl_').gsub('Create_temporary_tables', 'Create_tmp_table').gsub('Show_databases', 'Show_db')
                key = "#{key}_priv"
                incorrect_privs = true if r[key] != 'Y'
              end
            end

            password_up_to_date = incorrect_privs || test_user_password
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
                repair_sql += if new_resource.password.is_a?(MysqlPassword)
                                " PASSWORD '#{new_resource.password}'"
                              else
                                " '#{new_resource.password}'"
                              end
                repair_sql += ' REQUIRE SSL' if new_resource.require_ssl
                repair_sql += ' WITH GRANT OPTION' if new_resource.grant_option

                Chef::Log.info("#{@new_resource}: granting with sql [#{repair_sql}]")
                repair_client.query(repair_sql)
                repair_client.query('FLUSH PRIVILEGES')
              ensure
                close_repair_client
              end
            end
          else
            # The grants are correct, but perhaps the password needs updating?
            update_user_password unless password_up_to_date
          end
        end

        action :revoke do
          db_name = new_resource.database_name ? "`#{new_resource.database_name}`" : '*'
          tbl_name = new_resource.table ? new_resource.table : '*'
          test_table = new_resource.database_name ? 'mysql.db' : 'mysql.user'

          privs_to_revoke = []
          begin
            test_sql = "SELECT * from #{test_table}"
            test_sql += " WHERE User='#{new_resource.username}'"
            test_sql += " AND Host='#{new_resource.host}'"
            test_sql += " AND Db='#{new_resource.database_name}'" if new_resource.database_name
            test_sql_results = test_client.query test_sql

            # These should all be 'N'
            test_sql_results.each do |r|
              desired_privs.each do |p|
                key = p.to_s.capitalize.tr(' ', '_').gsub('Replication_', 'Repl_').gsub('Create_temporary_tables', 'Create_tmp_table').gsub('Show_databases', 'Show_db')
                key = "#{key}_priv"
                privs_to_revoke << revokify_key(p) if r[key] != 'N'
              end
            end
          ensure
            close_test_client
          end

          # Repair
          unless privs_to_revoke.empty?
            converge_by "Granting privs for '#{new_resource.username}'@'#{new_resource.host}'" do
              begin
                revoke_statement = "REVOKE #{privs_to_revoke.join(',')}"
                revoke_statement += " ON #{db_name}.#{tbl_name}"
                revoke_statement += " FROM `#{@new_resource.username}`@`#{@new_resource.host}` "

                Chef::Log.info("#{@new_resource}: revoking access with statement [#{revoke_statement}]")
                repair_client.query(revoke_statement)
                repair_client.query('FLUSH PRIVILEGES')
                @new_resource.updated_by_last_action(true)
              ensure
                close_repair_client
              end
            end
          end
        end

        private

        def desired_privs
          possible_global_privs = [
            :select,
            :insert,
            :update,
            :delete,
            :create,
            :drop,
            :references,
            :index,
            :alter,
            :create_tmp_table,
            :lock_tables,
            :create_view,
            :show_view,
            :create_routine,
            :alter_routine,
            :execute,
            :event,
            :trigger,
            :reload,
            :shutdown,
            :process,
            :file,
            :show_db,
            :super,
            :repl_slave,
            :repl_client,
            :create_user
          ]
          possible_db_privs = [
            :select,
            :insert,
            :update,
            :delete,
            :create,
            :drop,
            :references,
            :index,
            :alter,
            :create_tmp_table,
            :lock_tables,
            :create_view,
            :show_view,
            :create_routine,
            :alter_routine,
            :execute,
            :event,
            :trigger
          ]

          # convert :all to the individual db or global privs
          desired_privs = if new_resource.privileges == [:all] && new_resource.database_name
                            possible_db_privs
                          elsif new_resource.privileges == [:all]
                            possible_global_privs
                          else
                            new_resource.privileges
                          end
          desired_privs
        end

        def test_client
          require 'mysql2'
          @test_client ||=
            Mysql2::Client.new(
              host: new_resource.connection[:host],
              socket: new_resource.connection[:socket],
              username: new_resource.connection[:username],
              password: new_resource.connection[:password],
              port: new_resource.connection[:port]
            )
        end

        def close_test_client
          @test_client.close if @test_client
        rescue Mysql2::Error
          @test_client = nil
        end

        def repair_client
          require 'mysql2'
          @repair_client ||=
            Mysql2::Client.new(
              host: new_resource.connection[:host],
              socket: new_resource.connection[:socket],
              username: new_resource.connection[:username],
              password: new_resource.connection[:password],
              port: new_resource.connection[:port]
            )
        end

        def close_repair_client
          @repair_client.close if @repair_client
        rescue Mysql2::Error
          @repair_client = nil
        end

        def revokify_key(key)
          return '' if key.nil?

          # Some keys need to be translated as outlined by the table found here:
          # https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html
          result = key.to_s.downcase.tr('_', ' ').gsub('repl ', 'replication ').gsub('create tmp table', 'create temporary tables').gsub('show db', 'show databases')
          result = result.gsub(/ priv$/, '')
          result
        end

        def test_user_password
          if database_has_password_column(test_client)
            test_sql = 'SELECT User,Host,Password FROM mysql.user ' \
                       "WHERE User='#{new_resource.username}' AND Host='#{new_resource.host}' "
            test_sql += if new_resource.password.is_a? MysqlPassword
                          "AND Password='#{new_resource.password}'"
                        else
                          "AND Password=PASSWORD('#{new_resource.password}')"
                        end
          else
            test_sql = 'SELECT User,Host,authentication_string FROM mysql.user ' \
                       "WHERE User='#{new_resource.username}' AND Host='#{new_resource.host}' " \
                       "AND plugin='mysql_native_password' "
            test_sql += if new_resource.password.is_a? MysqlPassword
                          "AND authentication_string='#{new_resource.password}'"
                        else
                          "AND authentication_string=PASSWORD('#{new_resource.password}')"
                        end
          end
          test_client.query(test_sql).size > 0
        end

        def update_user_password
          converge_by "Updating password of user '#{new_resource.username}'@'#{new_resource.host}'" do
            begin
              if database_has_password_column(repair_client)
                repair_sql = "SET PASSWORD FOR '#{new_resource.username}'@'#{new_resource.host}' = "
                repair_sql += if new_resource.password.is_a? MysqlPassword
                                "'#{new_resource.password}'"
                              else
                                " PASSWORD('#{new_resource.password}')"
                              end
              else
                # "ALTER USER is now the preferred statement for assigning passwords."
                # http://dev.mysql.com/doc/refman/5.7/en/set-password.html
                repair_sql = "ALTER USER '#{new_resource.username}'@'#{new_resource.host}' "
                repair_sql += if new_resource.password.is_a? MysqlPassword
                                "IDENTIFIED WITH mysql_native_password AS '#{new_resource.password}'"
                              else
                                "IDENTIFIED BY '#{new_resource.password}'"
                              end
              end
              repair_client.query(repair_sql)
            ensure
              close_repair_client
            end
          end
        end

        def database_has_password_column(client)
          client.query('SHOW COLUMNS FROM mysql.user WHERE Field="Password"').size > 0
        end
      end
    end
  end
end
