#
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Author:: Sean OMeara (<sean@chef.io>)
# Copyright:: Copyright (c) 2011 Opscode, Inc.
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

class Chef
  class Provider
    class Database
      class Mysql < Chef::Provider::LWRPBase
        use_inline_resources if defined?(use_inline_resources)

        def whyrun_supported?
          true
        end

        action :create do
          # install mysql2 gem into Chef's environment
          mysql2_chef_gem 'default' do
            client_version node['mysql']['version'] if node['mysql']
          end.run_action(:install)

          # test
          schema_present = nil

          begin
            test_sql = 'SHOW SCHEMAS;'
            Chef::Log.debug("#{new_resource.name}: Performing query [#{test_sql}]")
            test_sql_results = test_client.query(test_sql)
            test_sql_results.each do |r|
              schema_present = true if r['Database'] == new_resource.database_name
            end
          ensure
            close_test_client
          end

          # repair
          unless schema_present
            converge_by "Creating schema '#{new_resource.database_name}'" do
              begin
                repair_sql = "CREATE SCHEMA IF NOT EXISTS `#{new_resource.database_name}`"
                repair_sql += " CHARACTER SET = #{new_resource.encoding}" if new_resource.encoding
                repair_sql += " COLLATE = #{new_resource.collation}" if new_resource.collation
                Chef::Log.debug("#{new_resource.name}: Performing query [#{repair_sql}]")
                repair_client.query(repair_sql)
              ensure
                close_repair_client
              end
            end
          end
        end

        action :drop do
          # install mysql2 gem into Chef's environment
          mysql2_chef_gem 'default' do
            client_version node['mysql']['version'] if node['mysql']
          end.run_action(:install)

          # test
          schema_present = nil

          begin
            test_sql = 'SHOW SCHEMAS;'
            Chef::Log.debug("Performing query [#{test_sql}]")
            test_sql_results = test_client.query(test_sql)
            test_sql_results.each do |r|
              schema_present = true if r['Database'] == new_resource.database_name
            end
          ensure
            close_test_client
          end

          # repair
          if schema_present
            converge_by "Dropping schema '#{new_resource.database_name}'" do
              begin
                repair_sql = "DROP SCHEMA IF EXISTS `#{new_resource.database_name}`"
                Chef::Log.debug("Performing query [#{repair_sql}]")
                repair_client.query(repair_sql)
              ensure
                close_repair_client
              end
            end
          end
        end

        private

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
          @test_client.close
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
          @repair_client.close
        rescue Mysql2::Error
          @repair_client = nil
        end
      end
    end
  end
end
