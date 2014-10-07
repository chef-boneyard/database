#
# Author:: Seth Chisamore (<schisamo@opscode.com>)
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

require 'chef/provider'

class Chef
  class Provider
    class Database
      class Mysql < Chef::Provider
        include Chef::Mixin::ShellOut

        def load_current_resource
          @current_resource = Chef::Resource::Database.new(@new_resource.name)
          @current_resource.database_name(@new_resource.database_name)
          @current_resource
        end

        def action_create
          unless exists?
            begin
              Chef::Log.debug("#{@new_resource}: Creating database `#{new_resource.database_name}`")
              create_sql = "CREATE DATABASE `#{db.escape(new_resource.database_name)}`"
              create_sql += " CHARACTER SET = #{db.escape(new_resource.encoding)}" if new_resource.encoding
              create_sql += " COLLATE = #{db.escape(new_resource.collation)}" if new_resource.collation
              Chef::Log.debug("#{@new_resource}: Performing query [#{create_sql}]")
              db.query(create_sql)
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
              db.query("DROP DATABASE `#{db.escape(new_resource.database_name)}`")
              @new_resource.updated_by_last_action(true)
            ensure
              close
            end
          end
        end

        def action_query
          if exists?
            begin
              db.select_db(@new_resource.database_name) if @new_resource.database_name
              Chef::Log.debug("#{@new_resource}: Performing query [#{new_resource.sql_query}]")
              db.query(@new_resource.sql_query)
              db.next_result while db.next_result
              @new_resource.updated_by_last_action(true)
            ensure
              close
            end
          end
        end

        private

        def exists?
          db.query("SHOW DATABASES LIKE '#{db.escape(@new_resource.database_name)}'").count > 0
        end

        def db
          unless @db
            Gem.clear_paths
            require 'mysql2'
            @db = Mysql2::Client.new(
              host: @new_resource.connection[:host],
              username: @new_resource.connection[:username],
              password: @new_resource.connection[:password],
              port: @new_resource.connection[:port] || 3306,
              database: @new_resource.connection[:socket] || nil,
              flags: Mysql2::Client::MULTI_STATEMENTS
            )
          end
          @db
        end

        def close
          @db.close rescue nil
          @db = nil
        end
      end
    end
  end
end
