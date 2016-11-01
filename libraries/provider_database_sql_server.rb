#
# Author:: Seth Chisamore (<schisamo@chef.io>)
# Copyright:: 2011-2016 Chef Software, Inc.
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

require 'chef/provider'

class Chef
  class Provider
    class Database
      class SqlServer < Chef::Provider
        include Chef::Mixin::ShellOut

        def load_current_resource
          Gem.clear_paths
          begin
            require 'tiny_tds'
          rescue LoadError
            Chef::Log.fatal('Could not load the required tiny_tds gem. Make sure to install this in your wrapper cookbook')
            raise
          end
          @current_resource = Chef::Resource::Database.new(@new_resource.name)
          @current_resource.database_name(@new_resource.database_name)
          @current_resource
        end

        def action_create
          unless exists?
            begin
              Chef::Log.debug("#{@new_resource}: Creating database #{new_resource.database_name}")
              create_sql = "CREATE DATABASE [#{new_resource.database_name}]"
              create_sql += " COLLATE #{new_resource.collation}" if new_resource.collation
              db.execute(create_sql).do
              @new_resource.updated_by_last_action(true)
            ensure
              close
            end
          end
        end

        def action_drop
          if exists?
            begin
              Chef::Log.debug("#{@new_resource}: Dropping database #{new_resource.database_name}")
              db.execute("DROP DATABASE [#{new_resource.database_name}]").do
              @new_resource.updated_by_last_action(true)
            ensure
              close
            end
          end
        end

        def action_query
          if exists?
            begin
              Chef::Log.debug("#{@new_resource}: Performing query [#{new_resource.sql_query}]")
              db.execute("USE [#{@new_resource.database_name}]").do if @new_resource.database_name
              db.execute(@new_resource.sql_query).do
              @new_resource.updated_by_last_action(true)
            ensure
              close
            end
          end
        end

        private

        def exists?
          exists = false
          begin
            result = db.execute('SELECT name FROM sys.databases')
            result.each do |row|
              if row['name'] == @new_resource.database_name
                exists = true
                break
              end
            end
            result.cancel
          ensure
            close
          end
          exists
        end

        def db
          @db ||= begin
            connection = ::TinyTds::Client.new(
              host: @new_resource.connection[:host],
              username: @new_resource.connection[:username],
              password: @new_resource.connection[:password],
              port: @new_resource.connection[:port] || 1433,
              timeout: @new_resource.connection[:timeout] || 120,
              options: @new_resource.connection[:options] || {}
            )
            if new_resource.connection.include?(:options)
              @new_resource.connection[:options].each do |key, value|
                connection.execute("SET #{key} #{value}").do
              end
            end
            connection
          end
        end

        def close
          begin
            @db.close
          rescue
            nil
          end
          @db = nil
        end
      end
    end
  end
end
